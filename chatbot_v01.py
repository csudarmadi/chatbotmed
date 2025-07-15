import json
from datetime import datetime
from langchain_community.llms import Ollama
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain.globals import set_verbose, set_debug

# ==== Konfigurasi Logging Langchain ====
set_verbose(False)
set_debug(False)

# ==== Inisialisasi LLM ====
llm = Ollama(
    model="llama3.2",
    temperature=0.0,
    top_p=0.9,
    num_ctx=2048,
    num_thread=4,
    stop=["</s>"],
    repeat_penalty=1.1,
    top_k=40
)

SYSTEM_PROMPT = """[INST] Anda adalah asisten medis terpercaya dan ringkas. Jawablah pertanyaan secara singkat (maksimal 3 kalimat) dan hanya berdasarkan informasi yang diminta. Fokus topik mencakup:
- Obat untuk penyakit kronis seperti diabetes tipe 2, hipertensi, dan kolesterol tinggi
- Efek samping, dosis umum, kontraindikasi, dan interaksi obat
- Tips penggunaan obat secara aman

Jangan berikan jawaban informasi yang tidak diminta dalam pertanyaan. Gunakan bahasa yang mudah dipahami pasien dewasa."""



prompt = ChatPromptTemplate.from_messages([
    ("system", SYSTEM_PROMPT),
    ("human", "{input}")
])

chain = prompt | llm | StrOutputParser()

def ask_llm(query: str) -> str:
    try:
        return chain.invoke({"input": query})
    except Exception as e:
        return f"Maaf, terjadi kesalahan NLP: {str(e)}"

# ==== Logging ====
def log_chat(user_msg, bot_msg, log_path="chat_logs.jsonl"):
    log_entry = {
        "timestamp": datetime.now().isoformat(),
        "user": user_msg,
        "bot": bot_msg
    }
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(log_entry, ensure_ascii=False) + "\n")

# ==== Chatbot Class ====
class Chatbot:
    def __init__(self, kb_source):
        if isinstance(kb_source, str):
            with open(kb_source, 'r', encoding='utf-8') as f:
                self.kb = json.load(f)
        elif isinstance(kb_source, dict):
            self.kb = kb_source
        else:
            raise ValueError("Knowledge base harus berupa path file atau dict.")
        self.chain = chain

    def normalize_text(self, text):
        return text.lower().strip()

    def find_obat_info(self, query):
        q = self.normalize_text(query)
        for cat, items in self.kb.items():
            for item in items:
                if self.normalize_text(item.get("nama", "")) in q:
                    return item, item.get("nama", "")
                for merk in item.get("merk_dagang", []):
                    if self.normalize_text(merk) in q:
                        return item, item.get("nama", "")
        return None, None
    
    def get_info(self, query):
        query_norm = self.normalize_text(query)
        category = None
        info = None

        for cat, items in self.kb.items():
            for item in items:
                if self.normalize_text(item["nama"]) in query_norm:
                    category = cat
                    info = item
                    break
                if "merk_dagang" in item:
                    for merk in item["merk_dagang"]:
                        if self.normalize_text(merk) in query_norm:
                            category = cat
                            info = item
                            break
            if info:
                break

        if not info:
            if self.chain:
                try:
                    llm_response = self.chain.invoke({"input": query_norm})
                    return llm_response if llm_response else "Maaf, saya belum bisa menjawab pertanyaan ini."
                except Exception as e:
                    return f"Maaf, terjadi kesalahan dalam pemrosesan LLM: {str(e)}. Silakan coba lagi."
            else:
                return "Informasi tidak ditemukan."

        is_efek_samping = "efek samping" in query_norm
        is_dosis = "dosis" in query_norm or "aturan pakai" in query_norm
        is_interaksi_obat = "interaksi obat" in query_norm or "interaksi" in query_norm
        is_catatan = "catatan khusus" in query_norm
        is_golongan = "golongan" in query_norm
        is_indikasi = "apa itu" in query_norm or "untuk apa" in query_norm or "apakah itu" in query_norm
        is_kategori_penyakit = "kategori penyakit" in query_norm or "penyakit" in query_norm

        response = f"{info['nama']}:\n"

        if is_golongan:
            golongan = info.get("golongan", "Tidak ada data")
            return f"Golongan obat {golongan}"

        elif is_kategori_penyakit:
            kategori = info.get("kategori_penyakit", "Tidak ada data")
            return f"Kategori penyakit {kategori}"

        elif is_indikasi:
            indikasi = info.get("indikasi", "Tidak ada data")
            return f"{indikasi}"

        elif is_efek_samping:
            efek_samping = ", ".join(info["efek_samping"]) if info["efek_samping"] else "Tidak ada data"
            return f"{efek_samping}"

        elif is_dosis:
            return f"{info['dosis']}"

        elif is_interaksi_obat:
            interaksi = "\n".join([f"{x['obat']}: {x['efek']}" for x in info["interaksi_obat"]]) if info["interaksi_obat"] else "Tidak ada data"
            return f"{interaksi}"

        elif is_catatan:
            catatan = info.get("catatan_khusus", "Tidak ada data")
            return f"Catatan khusus :\n{catatan}"

    # def get_info(self, query):
    #     query_norm = self.normalize_text(query)
    #     data, nama_obat = self.find_obat_info(query_norm)
    #     if not data:
    #         return None

    #     if "efek samping" in query_norm:
    #         efek = ", ".join(data.get("efek_samping", [])) or "-"
    #         return f"Efek samping dari {nama_obat}: {efek}"
    #     elif "dosis" in query_norm or "aturan pakai" in query_norm:
    #         return f"Dosis {nama_obat}: {data.get('dosis', '-')}"
    #     elif "interaksi obat" or "interaksi" in query_norm:
    #         interaksi = "\n".join([f"- {x['obat']}: {x['efek']}" for x in data.get("interaksi_obat", [])]) or "Tidak ada data"
    #         return f"Interaksi obat {nama_obat}: {interaksi}"
    #     elif "interaksi makanan" in query_norm:
    #         interaksi = "\n".join([f"- {x['makanan']}: {x['efek']}" for x in data.get("interaksi_makanan", [])]) or "Tidak ada data"
    #         return f"Interaksi makanan {nama_obat}: {interaksi}"
    #     elif "catatan khusus" in query_norm:
    #         return f"Catatan khusus {nama_obat}:\n{data.get('catatan_khusus', 'Tidak ada data')}"
    #     elif "golongan" in query_norm:
    #         return f"Golongan {nama_obat}: {data.get('golongan', '-')}"
    #     elif "indikasi" in query_norm or "untuk apa" or "apa itu" or "definisi" in query_norm:
    #         return f"Indikasi {nama_obat}: {data.get('indikasi', '-')}"
    #     else:
    #         return self.format_full_info(nama_obat, data)

    def format_full_info(self, nama, data):
        info = f"{nama}:"
        info += f"- Indikasi: {data.get('indikasi', '-')}"
        info += f"- Dosis: {data.get('dosis', '-')}"
        info += f"- Efek Samping: {', '.join(data.get('efek_samping', [])) or '-'}\n"
        if data.get("interaksi_obat"):
            info += "- Interaksi Obat:\n" + "\n".join([f"  - {x['obat']}: {x['efek']}" for x in data['interaksi_obat']]) + "\n"
        if data.get("interaksi_makanan"):
            info += "- Interaksi Makanan:\n" + "\n".join([f"  - {x['makanan']}: {x['efek']}" for x in data['interaksi_makanan']]) + "\n"
        if data.get("catatan_khusus"):
            info += f"- Catatan Khusus: {data['catatan_khusus']}\n"
        return info.strip()

# ==== Fungsi Utama ====
def get_bot_response(chatbot: Chatbot, user_input: str, priority="kb-first") -> str:
    user_input = user_input.strip()
    response = ""

    try:
        if priority == "llm-first":
            response = ask_llm(user_input)
            if not response or "Maaf" in response:
                kb_response = chatbot.get_info(user_input)
                if kb_response:
                    response = kb_response
        else:  # kb-first
            kb_response = chatbot.get_info(user_input)
            if kb_response:
                response = kb_response
            else:
                response = ask_llm(user_input)
    except Exception as e:
        response = f"Maaf, terjadi kesalahan dalam pemrosesan: {str(e)}"

    log_chat(user_input, response)
    return response

# ==== CLI ====
if __name__ == "__main__":
    bot = Chatbot("knowledge_base.json")
    print("Chatbot Medis Sindrom Metabolik. Ketik 'exit' untuk keluar.")
    while True:
        user_input = input("Anda: ")
        if user_input.lower().strip() == "exit":
            break
        reply = get_bot_response(bot, user_input, priority="kb-first")
        print(f"Bot: {reply}\n")

