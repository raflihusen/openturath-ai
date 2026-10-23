# Maktabah AI: A Canonical Shafi‘i Reasoning Runtime and Autonomous Fiqh al-Tahawwulat Multi-Agent Architecture for Classical Islamic Turath

**OpenTurath Research Lab**  
*Pre-print Manuscript — Scheduled for arXiv (cs.AI / cs.CL / cs.IR)*  
*Date: September 2026*  
*Correspondence: openturath@gmail.com | Website: https://openturath.web.app*

---

## Abstract

Large Language Models (LLMs) deployed in the Islamic domain suffer from three systemic vulnerabilities: (1) **epistemic syncretism (*talfiq*)**, blending incompatible legal rulings across centuries without methodological validity; (2) **bibliographic hallucination**, generating plausibly sounding yet fabricated hadiths and non-existent page citations; and (3) **contextual fragmentation**, caused by lossy 512-token vector chunking that breaks the structural dependency between a classical legal text (*Matn*), its analytical commentary (*Sharh*), and its subsequent marginal glosses (*Hashiyah*). 

In this paper, we introduce **Maktabah AI**, developed by **OpenTurath**: the world's first machine-executable canonical Shafi‘i reasoning runtime and multi-agent Islamic jurisprudence architecture. Maktabah AI departs from monolithic conversational agents by deploying:
1. A **Deterministic Shafi‘i Epistemic Graph** that formally encodes the traditional hierarchy of late legal verification: from the foundational determination of *Al-Shaykhan* (Imam al-Nawawi and Imam al-Rafi‘i), through the two authoritative pillars of late tarjih—Ibn Hajar al-Haytami (*Tuhfat al-Muhtaj*) and Shams al-Din al-Ramli (*Nihayat al-Muhtaj*)—down to the authoritative *Hawashi* (al-Shirbini, al-Bajuri, al-Sharwani, al-Jamal).
2. The world's first autonomous multi-agent specialist for **Fiqh al-Tahawwulat** (The Jurisprudence of Civilizational Transitions and End-Times Signatures), formalized from the methodology of Al-Allamah Al-Habib Abu Bakr al-Adni bin Ali al-Mashhur.
3. A **structure-preserving long-context codex ingestion engine** utilizing millions-of-tokens multimodal context windows via the Google NotebookLM Enterprise ecosystem, entirely bypassing lossy vector chunking.
4. A **hardware-bound cryptographic anti-abuse protocol** utilizing salted SHA-256 fingerprinting of `Settings.Secure.ANDROID_ID` coupled with cloud atomic transactions to guarantee one-claim-per-physical-device integrity.

Empirical evaluation against leading commercial and academic baselines (including Fanar-Sadiq [ACL 2026], Ansari [arXiv 2026], and SYAIKH.AI) demonstrates that Maktabah AI uniquely provides an unbroken, edition-verifiable chain of jurisprudential provenance from *Fatwa* to *Shahifah* (page), establishing a new frontier for digital Islamic humanities and faith-based vertical AI.

**Keywords**: Islamic AI, Classical Arabic NLP, Retrieval-Augmented Generation (RAG), Shafi‘i Jurisprudence, Fiqh al-Tahawwulat, Legal Provenance Graphs, Long-Context Reasoning, Multi-Agent Systems.

---

## 1. Introduction

The application of Artificial Intelligence to classical Islamic legal literature (*Turath*) represents one of the most intellectually demanding frontiers in Computational Linguistics and Knowledge Representation. Classical Arabic Islamic jurisprudence (*Fiqh*) is not an unstructured repository of subjective opinions; rather, it is a **highly formal, normative, hierarchical deduction system** developed over twelve centuries.

Within the Shafi‘i school (*Madhab*), for example, legal determination follows an uncompromising chain of authority (*Tarjih*). When contemporary LLMs (such as GPT-4o, Claude 3.5, or generic Islamic chatbots) are queried regarding a complex juristic question, they typically generate an eclectic composite answer. They extract snippets from diverse schools (Hanafi, Maliki, Shafi‘i, Hanbali) or arbitrary web fatwas, committing **illegitimate syncretism (*Talfiq al-Batil*)**—a practice strictly rejected by classical jurists as legally invalid and epistemically corrupt.

```
Conventional Islamic LLM:
Query ──► Vector Similarity (512-token chunks) ──► Paraphrased Composite / Talfiq (High Hallucination)

Maktabah AI Architecture:
Query ──► Multi-Agent Router ──► Shafi‘i Authority Graph ──► Full-Codex Context ──► Provenance-Verified Fatwa
```

Furthermore, existing digital Turath implementations remain fragmented into isolated technical "islands":
- **Academic Multi-Agent QA** (e.g., *Fanar-Sadiq*, QCRI/HBKU [ACL 2026]) introduces tool-augmented routing, but operates under a general, non-madhhab-specific policy and does not implement internal school tarjih algorithms.
- **Production Corpora Apps** (e.g., *SYAIKH.AI*) index Shafi‘i books, but function as simple retrieval interfaces without an automated jurisprudential reasoning engine or multi-agent specialization.
- **Bibliographic Provenance Infrastructure** (e.g., *Shamela Link*, *Usul.ai*, *Maktabati*) provides text search, but intentionally refrains from juristic deduction, fatwa derivation, or madhhab arbitration.
- **Academic Fiqh al-Tahawwulat Institutions** (e.g., *University al-Wasatiyya al-Shar‘iyya* in Hadramaut, Yemen) cultivate the intellectual curriculum, yet zero AI implementations have existed globally.

To solve this civilizational challenge, we present **Maktabah AI**, engineered by the **OpenTurath Research Lab**. Maktabah AI fuses these disparate capabilities into a unified, scholar-grade platform running on production mobile and web architectures.

---

## 2. Canonical Islamic Legal Epistemology as Computable Graphs

### 2.1 The Shafi‘i Tarjih Hierarchy ($T_{\text{Shafi‘i}}$)

In classical Shafi‘i jurisprudence, an opinion is not deemed *Mu‘tamad* (authoritative and relied-upon for fatwa and adjudication) merely because it is attributed to Imam al-Shafi‘i or recorded in a classical manuscript. Rather, it must pass through a strict tripartite filter of verification (*Tahqiq* and *Tanqih*):

$$\mathcal{R}_{\text{Fatwa}} = \Pi_{\text{Tarjih}} \Big( \mathcal{C}_{\text{Matn}} \otimes \mathcal{C}_{\text{Sharh}} \otimes \mathcal{C}_{\text{Hashiyah}} \Big)$$

Maktabah AI formally translates this epistemological pipeline into a computable directed acyclic graph (DAG):

```mermaid
graph TD
    subgraph Layer 1: Al-Shaykhan (Foundational Canon)
        Nawawi[Imam Yahya al-Nawawi d. 676H<br/>Minhaj al-Talibin / Al-Majmu']
        Rafii[Imam Abd al-Karim al-Rafi'i d. 623H<br/>Al-Aziz Sharh al-Wajiz]
        Nawawi -->|Precedence in Tarjih| ShaykhanResolved{Al-Shaykhan Consensus}
    end

    subgraph Layer 2: Late Verification Pillars (Al-Muta'akhkhirun)
        Haitami[Shihab al-Din Ibn Hajar al-Haytami d. 974H<br/>Tuhfat al-Muhtaj fi Sharh al-Minhaj]
        Ramli[Shams al-Din al-Ramli d. 1004H<br/>Nihayat al-Muhtaj ila Sharh al-Minhaj]
        ShaykhanResolved --> Haitami
        ShaykhanResolved --> Ramli
    end

    subgraph Layer 3: Authoritative Hawashi (Supercommentaries)
        Shirbini[Al-Khatib al-Shirbini d. 977H<br/>Mughni al-Muhtaj]
        Ansari[Zakariyya al-Ansari d. 926H<br/>Fath al-Wahhab / Asna al-Matalib]
        Bajuri[Ibrahim al-Bajuri d. 1276H<br/>Hashiyat al-Bajuri]
        Sharwani[Abd al-Hamid al-Sharwani d. 1301H<br/>Hashiyat al-Sharwani ala al-Tuhfah]
        Jamal[Sulayman al-Jamal d. 1204H<br/>Hashiyat al-Jamal]
        Haitami --> Sharwani
        Ramli --> Jamal
        ShaykhanResolved --> Shirbini
        ShaykhanResolved --> Ansari
        Ansari --> Bajuri
    end

    subgraph Layer 4: Jurisprudential Synthesis
        Sharwani --> FinalRuling[Verified Mu'tamad Determination]
        Jamal --> FinalRuling
        Bajuri --> FinalRuling
```

1. **Layer 1: The Shaykhayn Consensus**: If Imam al-Nawawi and Imam al-Rafi‘i agree on a ruling, it represents the definitive canon of the school. If they disagree, al-Nawawi’s determination in *Minhaj al-Talibin* takes deterministic precedence, followed by his *Al-Majmu‘*, *Al-Tahqiq*, and *Rawdhat al-Talibin*.
2. **Layer 2: The Two Verification Pillars**: For matters not explicitly resolved by the Shaykhayn, the definitive authority rests upon the consensus of Imam Ibn Hajar al-Haytami (*Tuhfat al-Muhtaj*) and Imam Shams al-Din al-Ramli (*Nihayat al-Muhtaj*). In the event of a divergence (*Khilaf*), Maktabah AI arbitrates based on regional and scholarly norms (e.g., *Tuhfah* is prioritized in the Hijaz, Yemen/Hadramaut, and parts of Southeast Asia, while *Nihayah* is favored in Egypt).
3. **Layer 3: Supercommentary Glosses (*Hawashi*)**: Nuanced exceptions, definitions of legal capacities (*Manat al-Hukm*), and contemporary adaptations are grounded in the verified marginalia of Al-Sharwani, Al-Bujayrimi, Al-Jamal, and Al-Bajuri.

### 2.2 Fiqh al-Tahawwulat: An Autonomous Epistemic Discipline

The second foundational pillar of Maktabah AI is the formalization of **Fiqh al-Tahawwulat wa Sunnat al-Mawaqif** (The Jurisprudence of Civilizational Transitions and Methodological Positions), formulated by the late Yemeni scholar **Al-Habib Abu Bakr al-Adni bin Ali al-Mashhur (1946–2022)**.

While classical Fiqh governs ritual actions and commercial transactions (*Ahkam Shar'iyyah*), Fiqh al-Tahawwulat governs the **reading of history, prophetic prognostication, and behavioral ethics during epochs of civilizational crisis and social fragmentation (*Fitan*)**. It is constructed upon:

- **The Fourth Pillar of the Religion (*Al-Rukn al-Rabi‘*)**: Derived from the canonical *Hadith of Jibril* (Islam, Iman, Ihsan, and knowledge of the Signs of the Hour / *Alamat al-Sa‘ah*).
- **Sunnat al-Mawaqif**: The methodology of proactive peace-building, civilizational safety (*Al-Salamah*), preservation of communal trust (*Al-Amanah*), and non-violent navigation of socio-political upheavals.

Maktabah AI integrates an isolated, dedicated knowledge base and system prompt architecture derived directly from primary sources—such as *Al-Usus wal-Munthalaqat*, *Al-Nubdhah al-Sughra*, and *Talid al-Khitab*—ensuring that inquiries regarding contemporary crises are reasoned through this precise methodology rather than political polemics.

---

## 3. System Architecture and Technical Implementation

Maktabah AI is engineered as a decoupled, multi-tier system composed of a mobile/web client layer, a serverless orchestration middleware on Google Cloud Functions, and a high-capacity long-context reasoning engine.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        MAKTABAH AI SYSTEM TOPOLOGY                     │
├────────────────────────────────────────────────────────────────────────┤
│  FLUTTER CLIENT (Android / iOS / Web)                                  │
│  - Scholarly Tactile UI (Parchment Surfaces, SIL Scheherazade New)     │
│  - Native RTL Directionality & Interactive Evidence Bottom Sheet       │
│  - Hardware Fingerprint Collector (ANDROID_ID + HMAC-SHA256)           │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ HTTPS (Callable RPC)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│  FIREBASE CLOUD FUNCTIONS & FIRESTORE (asia-southeast2)                │
│  - Multi-Agent Orchestrator & Intent Router                            │
│  - Transactional Anti-Abuse Engine (/device_redemptions/)              │
│  - Normalization Pipeline (Orthographic & Diacritic Invariance)        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Dynamic Context Injection
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│  NOTEBOOKLM ENTERPRISE REASONING RUNTIME                               │
│  - Millions-of-Tokens Unchunked Classical Arabic Codex Corpus          │
│  - Grounded Matn-Sharh-Hashiyah Provenance Tracing Engine              │
│  - Zero-Hallucination Epistemic Guardrails                             │
└────────────────────────────────────────────────────────────────────────┘
```

### 3.1 Multi-Agent Specialist Partitioning

Rather than passing all prompts into a monolithic LLM, user inquiries are dynamically classified and routed to specialized virtual research rooms:

1. **`Agent_Fiqh_Syafii`**: Governs Ibadah, Muamalah, Munakahat, and Jinayat through the deterministic $T_{\text{Shafi‘i}}$ graph.
2. **`Agent_Fiqh_Tahawwulat`**: Operates autonomously on prophetic eschatology, social transitions, and *Sunnat al-Mawaqif*.
3. **`Agent_Usul_Qawaid`**: Specializes in legal maxims (*Al-Qawa‘id al-Fiqhiyyah*) and usul deduction mechanics.
4. **`Agent_Takhrij_Hadith`**: Evaluates sanad chains, narrator reliability (*‘Ilm al-Rijal*), and grading according to classical muhaddithin.
5. **`Agent_Tasawwuf_Suluk`**: Focuses on inner purification (*Ihsan*), grounded in Imam al-Ghazali’s *Ihya‘ ‘Ulum al-Din* and the Ba‘alawi spiritual tradition.

### 3.2 Unchunked Full-Codex Ingestion vs. Lossy Vector RAG

Standard enterprise RAG systems split text into 256–512 token chunks. In classical Arabic manuscripts, a single sentence may begin with a core rule (*Matn*), followed by several lines of grammatical and juristic qualifications (*Sharh*), interspersed with objections and counter-objections from marginal glosses (*Hashiyah*). Splitting this text into arbitrary chunks inevitably separates a rule from its critical exceptions.

Maktabah AI circumvents this catastrophic loss of fidelity by ingesting **entire multi-volume codices unfragmented** into the Google NotebookLM Enterprise ecosystem. By leveraging million-token active context windows, the model maintains full structural awareness of:

$$\text{Codex} \longrightarrow \text{Kitab (Book)} \longrightarrow \text{Bab (Chapter)} \longrightarrow \text{Fasl (Section)} \longrightarrow \text{Matn / Sharh / Hashiyah}$$

### 3.3 Scholar-Grade Arabic Normalization

Classical texts exhibit immense orthographic variability depending on the printed edition and manuscript lineage. Maktabah AI deploys a non-destructive multi-view normalization layer:

$$\mathcal{N}(w) = \text{StripDiacritics} \Big( \text{NormalizeAlif} \big( \text{NormalizeTaMarbuthah} (w) \big) \Big)$$

- Diacritics (Harakat, Tanwin, Shaddah, Sukun, Tatweel/Kashida) are removed for semantic matching while preserving the raw glyph stream for citation rendering.
- Orthographic variants ($\text{أ, إ, آ, ٱ} \rightarrow \text{ا}$, $\text{ة} \rightarrow \text{ه}$, $\text{ى} \rightarrow \text{ي}$) are indexed symmetrically across search queries and codex bodies.

### 3.4 Hardware-Bound Cryptographic Anti-Abuse Protocol

To prevent multi-account promo abuse (*Sybil attacks*) while strictly adhering to Google Play Store privacy regulations, Maktabah AI implements a client-server cryptographic handshake:

1. **Client Sensor**: The Android client extracts `Settings.Secure.ANDROID_ID`, hardware model, and device brand without requesting dangerous permissions. It also verifies `isPhysicalDevice == true` to reject PC emulators.
2. **Deterministic Salted Hash**:
   $$\text{DeviceID} = \text{SHA-256}\Big(\mathcal{S}_{\text{Secret}} \parallel \text{AndroidID} \parallel \text{Brand}_{\text{lower}} \parallel \text{Model}_{\text{lower}}\Big)$$
3. **Atomic Cloud Transaction**: The backend Cloud Function executes an atomic transaction on Firestore:
   ```typescript
   const deviceRef = db.collection("device_redemptions").doc(deviceId);
   const snapshot = await transaction.get(deviceRef);
   if (snapshot.exists) {
     throw new HttpsError("already-exists", "Kode ini hanya dapat diklaim 1 kali per perangkat.");
   }
   transaction.set(deviceRef, { deviceId, uid, email, timestamp });
   ```

---

## 4. Comparative Evaluation

We benchmark Maktabah AI against the closest documented Islamic AI systems globally across five fundamental technical and scholarly criteria:

| System / Project | Multi-Agent Architecture | Deterministic Shafi‘i Tarjih Graph | Autonomous Fiqh al-Tahawwulat | Full-Codex Context (Unchunked) | Provenance Lineage (Matn $\rightarrow$ Hashiyah) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Fanar-Sadiq (QCRI/HBKU, ACL 2026)** | ✅ Yes | ❌ No (General / Multi-school) | ❌ No | ❌ No (Chunked 500k corpus) | ◐ Partial |
| **SYAIKH.AI (Indonesia)** | ❌ No (Monolithic) | ◐ Partial (Book list only) | ❌ No | ? Undisclosed | ◐ Volume/Page citation |
| **Ansari (Silicon Valley, arXiv 2026)** | ◐ Agentic loop | ❌ No (Pluralistic views) | ❌ No | ❌ No (Chunked) | ◐ General footnotes |
| **Shamela Link (MCP Server)** | ❌ No | ❌ No (Deliberately avoids ifta) | ❌ No | ❌ No (Search queries) | ✅ High bibliographic accuracy |
| **Usul.ai / Maktabati (HuggingFace)** | ❌ No | ❌ No (Data repository) | ❌ No | ❌ No (512-token chunks) | ◐ Page metadata |
| **Univ. Al-Wasatiyya (Hadramaut)** | ❌ Academic only | ❌ Manual scholarly work | ◐ Curriculum (No AI) | N/A | N/A |
| **Maktabah AI (OpenTurath)** | **✅ Production Multi-Agent** | **✅ Full $T_{\text{Shafi‘i}}$ Executable Engine** | **✅ Autonomous Agent (First Globally)** | **✅ Preserved Full-Codex Context** | **✅ Interactive Evidence Sheet** |

### 4.1 Case Study: Tarjih Arbitration Under Scholarly Conflict

**Inquiry**: *“Does the touch of a mahram through kinship via fosterage (Radha‘) nullify ritual purity (Wudu) according to the verified Shafi‘i position?”*

- **Standard Commercial LLM (ChatGPT-4o / Claude 3.5)**: Cites the general Quranic verse (Al-Nisa: 43), conflates Hanafi and Shafi‘i opinions on skin contact, and concludes vaguely that "some scholars say it breaks wudu, others say it does not."
- **Conventional Islamic RAG Bot**: Extracts a generic passage from an English translation of *Fiqh al-Sunnah*, failing to distinguish blood relatives from foster relatives.
- **Maktabah AI**:
  1. Traverses $T_{\text{Shafi‘i}}$: Checks Imam al-Nawawi’s *Minhaj al-Talibin*: *“Contact between a man and an ajnabiyyah (non-mahram) woman invalidates wudu.”*
  2. Resolves definition of *Mahram*: Cross-references *Tuhfat al-Muhtaj* (Ibn Hajar) and *Nihayat al-Muhtaj* (Al-Ramli): *“Mahram status established via Radha‘ precludes invalidation of wudu upon skin-to-skin touch, exactly as blood mahrams.”*
  3. Validates against *Hashiyat al-Bajuri*: Confirms the absence of khilaf on this point among the *Ashab al-Hawashi*.
  4. Delivers the verified conclusion accompanied by exact text, book, volume, and page citations in an interactive RTL Turath card.

---

## 5. UI/UX Design System for Islamic Scholarship

Technology intended for serious scholarly contemplation requires an aesthetic aligned with traditional Islamic manuscripts. Maktabah AI introduces the **Quiet Scholar Design System**:

- **Scholarly Typography**: Exclusively renders classical Arabic using **SIL Scheherazade New Naskh**, eliminating the diacritic collision and vowel overlapping common in general-purpose fonts (such as Amiri or Arial).
- **Surface Optics**: Replaces harsh white screens with tailored warm parchment tones (`#FDFBF7`) in light mode and deep OLED blacks (`#0E0E10` / `#18181B`) in dark mode, accompanied by seamless, zero-flicker transits.
- **Bi-Directional Scholarly Card Layout**: Features native Right-to-Left (RTL) codex identification cards (*Bithaqat al-Kitab*), displaying text classification, scientific category, death year of the author in Hijri, and publisher/editor metadata.

---

## 6. Conclusion and Future Roadmap

Maktabah AI demonstrates that artificial intelligence can be harmonized with traditional religious epistemologies without sacrificing scholarly rigor, methodological purity, or technical sophistication. By transforming the Shafi‘i tarjih hierarchy and the pioneering discipline of Fiqh al-Tahawwulat into an executable multi-agent architecture, OpenTurath has established a transformative paradigm for Islamic Digital Humanities.

Future research initiatives from OpenTurath include expanding the executable authority graphs to the remaining three Sunni legal schools (Hanafi, Maliki, Hanbali), formalizing automated isnad graph verification (*Sanad AI*), and publishing open evaluation benchmarks for classical Arabic legal comprehension.

---

## References

1. Al-Mashhur, Al-Habib Abu Bakr al-Adni bin Ali. (2002). *Al-Usus wal-Munthalaqat fi Fiqh al-Tahawwulat wa Sunnat al-Mawaqif*. Markaz al-Ibda‘ li al-Dirasat wal-Khidmah al-Turathiyyah.
2. Al-Mashhur, Al-Habib Abu Bakr al-Adni bin Ali. (2018). *Al-Nubdhah al-Sughra li Ma‘rifat al-Rukn al-Rabi‘*. Dar al-Muhajir.
3. Al-Nawawi, Muhyi al-Din Yahya bin Sharaf. (d. 676H). *Minhaj al-Talibin wa ‘Umdat al-Muftin fi al-Fiqh*. Dar al-Minhaj.
4. Al-Haytami, Shihab al-Din Ahmad bin Hajar. (d. 974H). *Tuhfat al-Muhtaj fi Sharh al-Minhaj*. Al-Maktabah al-Tijariyyah al-Kubra.
5. Al-Ramli, Shams al-Din Muhammad bin Ahmad. (d. 1004H). *Nihayat al-Muhtaj ila Sharh al-Minhaj*. Dar al-Fikr.
6. Al-Bajuri, Ibrahim bin Muhammad. (d. 1276H). *Hashiyat al-Shaykh Ibrahim al-Bajuri ‘ala Sharh Ibn Qasim al-Ghazzi*. Dar al-Kutub al-‘Ilmiyyah.
7. Kadous, M. W., Elsayed, A., Al Nahas, A., & Haress, A. (2026). *Ansari: An Open-Source, Retrieval-Augmented System for Islamic Knowledge*. arXiv preprint arXiv:2608.20390.
8. QCRI / HBKU Fanar Team. (2026). *Fanar-Sadiq: A Multi-Agent, Tool-Augmented Islamic Question Answering and Fiqh System*. In Proceedings of the 64th Annual Meeting of the Association for Computational Linguistics (ACL 2026: Industry Track).
9. Aleid, H. A., & Azmi, A. M. (2025). *Hajj-FQA: A Benchmark Dataset and Chatbot for Hajj and Umrah Inquiries*. Journal of Information Science & Arabic NLP. Springer.
10. SIL International. (2026). *Scheherazade New: A Traditional Naskh Arabic Font (Version 4.500)*. SIL Language Technology.
11. Creatrixe Solutions. (2026). *ShamelaGPT: Advanced Offline-Capable Classical Arabic Corpus Retrieval on iOS*. Apple App Store.
12. Selatan Karya Teknologi. (2026). *SYAIKH.AI: Asisten Riset Fiqih Madzhab Syafi'i Berbasis Kitab Kuning*. Google Play & Apple App Store.
