# OECD Calabria - Professional Qualifications Repertoire

## Description
This project analyzes the Professional Qualifications Repertoire of the Calabria Region, integrating data from 299 Excel files. The Regional Qualifications Repertoire is the official list of professional profiles and competencies that each Italian Region recognizes and certifies through its vocational training system. 

Each profile (qualification) is described in terms of knowledge (know-what) and skills/competencies (know-how) necessary to perform specific work activities. Although managed locally, the repertoire feeds into the National Framework of Regional Qualifications (QNQR), ensuring that qualifications obtained in one region are valid throughout Italy and transparent for recognition in Europe (through the EQF - European Qualifications Framework). All regional profiles and their national correspondences are also available through the Atlas of Work and Qualifications managed by INAPP (https://www.inapp.gov.it/atlantelavoro/).

## Technologies & Tools

### Data Processing
- **Polars** - High-performance DataFrame library for data manipulation and transformation
- **Python 3.12** - Core programming language
- **PostgreSQL** - Relational database for storing qualifications data

### Data Visualization
- **NetworkX** - Graph creation and analysis
- **PyVis** - Interactive network visualizations
- **Matplotlib** - Static graph visualizations
- **Vis.js** - JavaScript network visualization library

### Graph Database
- **Neo4j AuraDB** - Cloud-based graph database for relationship analysis
- **Cypher** - Query language for Neo4j

### Data Sources
- **Lightcast (formerly Emsi Burning Glass)** - Job postings and labor market data
- **INAPP Atlas** - National professional classifications (ADA, CP2021)
- **Regional Training Catalogue** - Calabria professional qualifications

### Environment
- **Docker** - Containerized development environment
- **UV** - Fast Python package installer
- **Jupyter** - Interactive notebook environment

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
│   ├── rtc_prep.ipynb                      # RTC data preparation and cleaning
│   ├── lightast_prep.ipynb                 # Lightcast job postings data preparation
│   ├── graph_creation_ada.ipynb            # ADA-Attivita-SEP graph creation & Neo4j export
│   ├── graph_creation_from_db.ipynb        # Database-driven graph creation
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
    ├── ada_attivita_sep_graph.html         # Interactive ADA-Activities-SEP graph
    ├── neo4j_import.cypher                 # Neo4j Cypher import commands
    ├── ojp_and_skills_calabria_nested.parquet # Processed job postings with skills
    └── ada_and_attivita_nested.parquet     # Processed ADA with nested activities
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

## Analysis Notebooks

The project includes four Jupyter notebooks for data processing, analysis, and visualization:

### 1. rtc_prep.ipynb - Regional Training Catalogue Data Preparation
**Purpose:** Prepares and cleans the Regional Training Catalogue (RTC) data for analysis.

**Key Operations:**
- Loads ADA (Area of Activity), Attivita (Activities/Skills), and CP2021 (Professional Classifications) datasets
- Converts data types (e.g., SEP codes to strings)
- Identifies and analyzes duplicates in the activities dataset
- Merges ADA data with CP2021 professional classifications
- Creates nested data structures grouping activities by ADA codes
- Exports processed data to: `../data/rtc/ada_and_attivita_nested.parquet`

**Output:** Clean, nested Polars dataframes ready for graph creation and analysis.

### 2. lightast_prep.ipynb - Lightcast Job Postings Data Preparation
**Purpose:** Processes Lightcast job posting data for the Calabria region and maps it to professional taxonomies.

**Key Operations:**
- Loads Italian job postings from 2025 dataset (ITA_2025_postings.parquet)
- Filters postings for Calabria region (LAA_ADMIN_AREA_1 == "ITF6")
- Removes undefined (99) and volunteer (29) career areas
- Automatically decodes taxonomy codes using Lightcast dictionaries:
  - Location (LAA), Occupation (LOT), Industry (NAICS), Professional (ISCO-08)
  - Skill categories and subcategories
- Merges job postings with skills data
- Creates nested structure with skills embedded as lists of structs for each posting
- Adds row index for tracking
- Exports processed data to: `../data/lightcast/ojp_and_skills_calabria_nested.parquet`

**Output:** ~26,000 job postings with nested skills data, ready for labor market analysis.

### 3. graph_creation_ada.ipynb - ADA Network Graph Creation & Neo4j Export
**Purpose:** Creates interactive network visualizations of ADA-Activities-SEP relationships and exports to Neo4j.

**Key Operations:**
- Loads nested ADA and activities data from parquet files
- Builds NetworkX graph with three node types:
  - **ADA nodes** (Blue, Professional Activities): ~540 nodes
  - **Attivita nodes** (Red/Purple, Skills): ~3,800 nodes
  - **SEP nodes** (Green, Economic Sectors): ~25 nodes
- Creates edges representing relationships between:
  - ADA → Attivita (skills required for each activity area)
  - ADA → SEP (sector classification)
- Generates multiple visualizations:
  - **Matplotlib**: Static PNG with spring layout
  - **PyVis**: Interactive HTML with pre-computed layout for fast loading
- Exports to Neo4j AuraDB:
  - Generates Cypher commands for graph database import
  - Creates constraints and indexes
  - Establishes relationships: `HAS_ATTIVITA` and `BELONGS_TO_SEP`
  - Provides Python code for automated import using neo4j driver

**Outputs:**
- `/app/outputs/ada_attivita_sep_graph.html` - Interactive graph visualization
- `/app/outputs/neo4j_import.cypher` - Neo4j import script

**Features:**
- Physics-disabled layout for instant loading
- Color-coded node types
- Hover tooltips with detailed information
- SEP nodes have persistent labels for quick identification

### 4. graph_creation_from_db.ipynb - Database-Driven Graph Creation
**Purpose:** Creates network graphs directly from PostgreSQL database queries.

**Key Operations:**
- Connects to PostgreSQL database containing regional qualifications data
- Queries profiles, competencies, and their relationships
- Builds bipartite network graphs
- Generates interactive PyVis visualizations
- Exports to: `/app/outputs/profili_comp_graph.html`

**Output:** Interactive HTML graphs showing relationships between professional profiles and competencies.

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

## Getting Started

### Prerequisites
- Docker Desktop or Docker Engine
- VS Code with Dev Containers extension (recommended)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd OECD_calabria
   ```

2. **Start the development container**
   ```bash
   # Using VS Code
   # Open folder in VS Code and select "Reopen in Container"
   
   # Or using Docker Compose
   docker-compose up -d
   ```

3. **Install Python dependencies**
   ```bash
   source /app/.venv/bin/activate
   uv sync
   ```

4. **Install additional packages for notebooks**
   ```bash
   uv add polars networkx pyvis matplotlib neo4j python-dotenv
   ```

### Running the Analysis

The notebooks should be run in the following order:

1. **rtc_prep.ipynb** - Prepare Regional Training Catalogue data
   - Loads and cleans ADA, Activities, and CP2021 data
   - Outputs: `ada_and_attivita_nested.parquet`

2. **lightast_prep.ipynb** - Prepare Lightcast job postings data
   - Filters and decodes Calabria job postings
   - Maps to professional taxonomies
   - Outputs: `ojp_and_skills_calabria_nested.parquet`

3. **graph_creation_ada.ipynb** - Create network visualizations
   - Generates interactive graphs
   - Exports Neo4j import scripts
   - Outputs: HTML visualizations and Cypher files

4. **graph_creation_from_db.ipynb** - Create database-driven graphs
   - Requires PostgreSQL database setup
   - Generates profile-competency graphs

### Neo4j Integration

To import the graph into Neo4j AuraDB:

1. **Create a free AuraDB instance** at https://console.neo4j.io/

2. **Configure environment variables**
   Create `/app/.env` file:
   ```bash
   NEO4J_URI=neo4j+s://your-instance.databases.neo4j.io
   NEO4J_USERNAME=neo4j
   NEO4J_PASSWORD=your-password
   ```

3. **Run the import**
   Execute the Neo4j import cell in `graph_creation_ada.ipynb`
   or use the generated Cypher file via Neo4j Browser

### Viewing Outputs

- **Interactive graphs**: Open HTML files in `/app/outputs/` with any web browser
- **Data files**: Parquet files can be opened with Polars, Pandas, or DuckDB
- **Cypher scripts**: Import into Neo4j Browser or use with Python neo4j driver

## Project Outputs

### Processed Data Files
- `ada_and_attivita_nested.parquet` - Nested ADA data with activities (~540 ADAs, ~3,800 activities)
- `ojp_and_skills_calabria_nested.parquet` - Job postings with skills (~26,000 postings)

### Visualizations
- `ada_attivita_sep_graph.html` - Interactive network graph (ADA-Activities-SEP)
- `profili_comp_graph.html` - Profile-competency relationships
- `neo4j_import.cypher` - Graph database import script

### Statistics
- **Calabria Job Postings**: ~26,137 postings (after filtering)
- **Job Postings with Skills**: ~22,527 postings
- **Professional Activity Areas (ADA)**: ~540 unique areas
- **Activities/Skills**: ~3,800 unique activities
- **Economic Sectors (SEP)**: ~25 sectors
- **Network Edges**: ~4,000+ relationships

## Contributing

This project is part of the OECD initiative to analyze regional labor markets and professional qualifications in Calabria, Italy.