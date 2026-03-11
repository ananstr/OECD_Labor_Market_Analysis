# OECD Calabria - Professional Qualifications Repertoire

## Description
This project analyzes the Professional Qualifications Repertoire of the Calabria Region, integrating data from 299 Excel files. The Regional Qualifications Repertoire is the official list of professional profiles and competencies that each Italian Region recognizes and certifies through its vocational training system. 

Each profile (qualification) is described in terms of knowledge (know-what) and skills/competencies (know-how) necessary to perform specific work activities. Although managed locally, the repertoire feeds into the National Framework of Regional Qualifications (QNQR), ensuring that qualifications obtained in one region are valid throughout Italy and transparent for recognition in Europe (through the EQF - European Qualifications Framework). All regional profiles and their national correspondences are also available through the Atlas of Work and Qualifications managed by INAPP (https://www.inapp.gov.it/atlantelavoro/).

## Project Structure

```
├── docker-compose.yml          # Docker container orchestration
├── Dockerfile                  # Docker configuration
├── init.sql                    # Database initialization script
├── pyproject.toml             # Python project configuration
├── Readme.md                  # Project documentation
│
├── data/                      # Data directory
│   ├── isco08_cp2021_crosswalk.csv         # ISCO08 to CP2021 mapping
│   ├── regcal_profili_rev2.numbers         # Regional profiles (Numbers format)
│   │
│   ├── lightcast/             # Lightcast job postings data
│   │   ├── Complete_VarDictionary.csv      # Variable dictionary
│   │   ├── ITA_2025_postings.csv          # Italian job postings 2025
│   │   └── dictionaries/
│   │       ├── full_skill_list.csv        # Complete skills list
│   │       └── skill_definitions.numbers  # Skill definitions
│   │
│   └── rtc/                   # Regional Technical Committee data
│       ├── ada_cp2021.csv                  # ADA to CP2021 mapping
│       ├── attivita_ada.csv                # ADA activities
│       ├── competenze.sql                  # Competencies SQL
│       ├── five_digit-cp2021.csv          # 5-digit CP2021 codes
│       ├── profili.sql                     # Profiles SQL
│       ├── regcal_abilita_rev2.csv        # Skills (revision 2)
│       ├── regcal_attivita_rev2.csv       # Activities (revision 2)
│       ├── regcal_competenze_rev2.csv     # Competencies (revision 2)
│       ├── regcal_conoscenze_rev2.csv     # Knowledge (revision 2)
│       └── regcal_profili_rev2.csv        # Profiles (revision 2)
│
├── meeting_notes/             # Meeting notes and documentation
│
├── notebooks/                 # Jupyter notebooks for analysis
│   ├── graph_creation_ada.ipynb            # ADA graph creation
│   ├── graph_creation.ipynb                # General graph creation
│   ├── lightast_prep.ipynb                 # Lightcast data preparation
│   ├── rtc_prep.ipynb                      # RTC data preparation
│   └── lib/                   # JavaScript libraries for visualization
│       ├── bindings/
│       │   └── utils.js
│       ├── tom-select/
│       │   ├── tom-select.complete.min.js
│       │   └── tom-select.css
│       └── vis-9.1.2/
│           ├── vis-network.css
│           └── vis-network.min.js
│
└── outputs/                   # Generated outputs
    ├── ada_attivita_cp2021_graph.html      # ADA-Activities-CP2021 graph
    ├── ada_attivita_graph.html             # ADA-Activities graph
    ├── codice_ada_codice_cp2021_graph.html # ADA-CP2021 codes graph
    └── profili_comp_graph.html             # Profiles-Competencies graph
```

## Data Structure

The extraction consists of 5 interconnected datasets linked through identifying fields:

### Profiles (profili)
- `id_profilo` - Profile ID
- `titolo` - Title
- `descrizione` - Description
- `liv_eqf` - EQF level
- `settore` - Sector
- `ada_1..ada_47` - Up to 47 different ADA codes

### Competencies (competenze)
- `id_competenza` - Competency ID
- `id_profilo` - Profile ID (foreign key)
- `titolo` - Title
- `descrizione` - Description
- `risultato` - Result

### Knowledge (conoscenze)
- `id_conoscenza` - Knowledge ID
- `id_competenza` - Competency ID (foreign key)
- `descrizione` - Description

### Activities (attivita)
- `id_attivita` - Activity ID
- `id_competenza` - Competency ID (foreign key)
- `descrizione` - Description

### Skills (abilita)
- `id_abilita` - Skill ID
- `id_competenza` - Competency ID (foreign key)
- `descrizione` - Description

## Data Quality Notes

### Data Consistency
The core entity is the competency, which references a profile and is in turn referenced by knowledge, activities, and skills. The profiles, competencies, and activities datasets are consistent (without duplicates or ambiguities), while knowledge and skills present anomalies: with matching identifiers, different descriptions are found.

### Profiles
Up to 47 different ADA codes are expected. The profile with the most codes is `id_profilo=2012` (title: "Operatore addetto alle lavorazioni in filiere agroalimentari") with 12 codes.

### Competencies
Only 3 competencies have a "result" indicated; all others lack this information.

### ADA/Results
Regional Qualifications (in the "profiles" dataset) can be associated with "ADA - Activity Areas" from INAPP's Atlas of Work and Qualifications. ADAs represent detailed descriptions of tasks performed in a profession, organized according to a hierarchical structure starting from Professional Economic Sectors (SEP). Each ADA includes:
- Description of activities (list of specific tasks)
- Expected results: products or services that must result from the activity and related performance standards

### Training Courses
The dataset does not contain information about authorized or activated training courses in the Calabria Region.