import json
from datetime import datetime
from difflib import get_close_matches
from langchain_community.llms import Ollama
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain.globals import set_verbose, set_debug

# Disable verbose logging for production
set_verbose(False)
set_debug(False)

# Initialize Ollama LLM
llm = Ollama(
    model="llama3.2",
    temperature=0.7,
    top_p=0.9,
    num_ctx=2048,
    num_thread=4,
    stop=["</s>"],
    repeat_penalty=1.1,
    top_k=40
)

SYSTEM_PROMPT = """[INST] Anda adalah asisten medis yang efisien. Berikan jawaban singkat (maks 3 kalimat) tentang:
- Obat untuk Penyakit Kronis (diabetes, hipertensi, kolesterol)
- Efek samping, dosis, dan interaksi obat
- Tips penggunaan obat\"[/INST]"""

prompt = ChatPromptTemplate.from_messages([
    ("system", SYSTEM_PROMPT),
    ("human", "{input}")
])

chain = prompt | llm | StrOutputParser()

def log_chat(user_msg, bot_msg, log_path="chat_logs.jsonl"):
    log_entry = {
        "timestamp": datetime.now().isoformat(),
        "user": user_msg,
        "bot": bot_msg
    }
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(log_entry, ensure_ascii=False) + "\n")

class Chatbot:
    def __init__(self, knowledge_base):
        if isinstance(knowledge_base, str):
            with open(knowledge_base, 'r', encoding='utf-8') as f:
                self.kb = json.load(f)
        elif isinstance(knowledge_base, dict):
            self.kb = knowledge_base
        else:
            raise ValueError("Parameter knowledge_base harus berupa string path file JSON atau dictionary")

    def find_category(self, query):
        query = self.normalize_text(query)
        for category in self.kb:
            if self.normalize_text(category) in query:
                return category
        for category, value in self.kb.items():
            if 'subkategori' in value:
                for subcat in value['subkategori']:
                    if self.normalize_text(subcat) in query:
                        return category
        matches = get_close_matches(query, self.kb.keys(), n=1, cutoff=0.5)
        return matches[0] if matches else None

    def find_subcategory(self, category, query):
        if category and 'subkategori' in self.kb[category]:
            subcats = list(self.kb[category]['subkategori'].keys())
            for subcat in subcats:
                if self.normalize_text(subcat) in self.normalize_text(query):
                    return subcat
            for subcat, detail in self.kb[category]['subkategori'].items():
                for example in detail.get('contoh_obat', []):
                    if self.normalize_text(example) in self.normalize_text(query):
                        return subcat
            matches = get_close_matches(query, subcats, n=1, cutoff=0.5)
            if matches:
                return matches[0]
        return None

    def normalize_text(self, text):
        return text.lower().strip()

    def get_info(self, query):
        query_norm = self.normalize_text(query)
        category = None

        # Cari kategori berdasarkan ketersediaan
        for key in self.kb.keys():
            for item in self.kb[key]:
                if self.normalize_text(item["nama"]) in query_norm:
                    category = key
                    break
            if category:
                break

        if not category:
            return "Informasi tidak ditemukan."

        # Cari obat dalam kategori
        for item in self.kb[category]:
            if self.normalize_text(item["nama"]) in query_norm:
                info = item
                break
        else:
            return "Informasi tidak ditemukan."

        # Handle query spesifik
        is_efek_samping = "efek samping" in query_norm
        is_dosis = "dosis" in query_norm or "aturan pakai" in query_norm
        is_interaksi_obat = "interaksi obat" in query_norm
        is_interaksi_makanan = "interaksi makanan" in query_norm
        is_catatan = "catatan khusus" in query_norm

        response = f"{info['nama']}:\n"

        if is_efek_samping:
            efek_samping = ", ".join(info["efek_samping"]) if info["efek_samping"] else "Tidak ada data"
            return f"Efek samping {info['nama']}:\n{efek_samping}"

        elif is_dosis:
            return f"Dosis {info['nama']}:\n{info['dosis']}"

        elif is_interaksi_obat:
            interaksi = "\n".join([f"{x['obat']}: {x['efek']}" for x in info["interaksi_obat"]]) if info["interaksi_obat"] else "Tidak ada data"
            return f"Interaksi obat {info['nama']}:\n{interaksi}"

        elif is_interaksi_makanan:
            interaksi = "\n".join([f"{x['makanan']}: {x['efek']}" for x in info["interaksi_makanan"]]) if info.get("interaksi_makanan") else "Tidak ada data"
            return f"Interaksi makanan {info['nama']}:\n{interaksi}"

        elif is_catatan:
            catatan = info.get("catatan_khusus", "Tidak ada data")
            return f"Catatan khusus {info['nama']}:\n{catatan}"

        else:  # Tampilkan semua informasi
            response += f"Indikasi: {info['indikasi']}\n"
            response += f"Dosis: {info['dosis']}\n"
            if info["efek_samping"]:
                response += f"Efek samping: {', '.join(info['efek_samping'])}\n"
            if info["interaksi_obat"]:
                response += "Interaksi obat:\n" + "\n".join([f"- {x['obat']}: {x['efek']}" for x in info["interaksi_obat"]]) + "\n"
            if info.get("interaksi_makanan"):
                response += "Interaksi makanan:\n" + "\n".join([f"- {x['makanan']}: {x['efek']}" for x in info["interaksi_makanan"]]) + "\n"
            if info.get("catatan_khusus"):
                response += f"Catatan khusus: {info['catatan_khusus']}\n"
            return response

    def format_subcategory_info(self, subcat, subval):
        info = f"{subcat}:\n"
        info += f"Deskripsi: {subval.get('deskripsi', '-')}\n"
        contoh_obat = ', '.join(subval.get('contoh_obat', []))
        info += f"Contoh Obat: {contoh_obat if contoh_obat else '-'}\n"
        info += f"Dosis Umum: {subval.get('dosis_umum', '-')}\n"
        efek_samping = ', '.join(subval.get('efek_samping', []))
        info += f"Efek Samping: {efek_samping if efek_samping else '-'}"
        return info

def get_bot_response(chatbot_obj, user_input, priority="kb-first"):
    response = ""
    try:
        if priority == "llm-first":
            response = chain.invoke({"input": user_input})
            if not response or "Maaf" in response:
                kb_answer = chatbot_obj.get_info(user_input)
                if kb_answer:
                    response = kb_answer
        else:  # kb-first
            kb_answer = chatbot_obj.get_info(user_input)
            if kb_answer:
                response = kb_answer
            else:
                response = chain.invoke({"input": user_input})
    except Exception as e:
        response = "Maaf, terjadi kesalahan dalam pemrosesan. Silakan coba lagi."
        print(f"Error: {str(e)}")
    log_chat(user_input, response)
    return response

if __name__ == "__main__":
    bot = Chatbot('knowledge_base.json')
    print("Chatbot Medis Sindrom Metabolik. Ketik 'exit' untuk keluar.")
    while True:
        user_input = input("Anda: ").strip()
        if user_input.lower() == "exit":
            break
        bot_reply = get_bot_response(bot, user_input, priority="kb-first")
        print(f"Bot: {bot_reply}\n")