# 🏗️ Data Warehouse & Analytics Project

> *"20+ years of business experience — now turned into clean, structured data."*

---

## 📌 What This Project Is About

This project builds a **modern Data Warehouse from scratch** using SQL Server and DBeaver — following the **Medallion Architecture** (Bronze → Silver → Gold).

It combines two things I know well: **how businesses actually work**, and **how data should be structured** to make decisions faster and smarter.

The end result: raw sales data from two source systems (ERP & CRM) transformed into a clean, analytics-ready data model — with SQL-based reporting on top.

---

## 🏛️ Architecture Overview

```
ERP Data (CSV)  ──┐
                  ├──▶  [Bronze Layer]  ──▶  [Silver Layer]  ──▶  [Gold Layer]  ──▶  Analytics
CRM Data (CSV)  ──┘
    Raw Ingestion         Cleanse & Validate      Model & Enrich         Insights
```

| Layer | Purpose |
|-------|---------|
| 🥉 **Bronze** | Load raw data as-is from source systems — no transformations |
| 🥈 **Silver** | Cleanse, standardize, validate and enrich the data |
| 🥇 **Gold** | Build dimension and fact tables ready for analysis |

---

## 🎯 Project Goals

**Data Engineering:**
- Import sales data from ERP and CRM source systems (CSV)
- Resolve data quality issues before analysis
- Combine both sources into a single, clean data model

**Analytics & Reporting:**
- Customer Behavior
- Product Performance
- Sales Trends

---

## 🛠️ Tech Stack

| Tool | Role |
|------|------|
| **SQL Server Express** | Database engine (local) |
| **T-SQL** | ETL, stored procedures, data modeling |
| **DBeaver** | SQL client & schema management |
| **Git & GitHub** | Version control & portfolio |
| **Notion** | Project management & documentation |
| **Draw.io** | Data flow diagrams |

---

## 📁 Repository Structure

```
sql-data-warehouse-project/
│
├── datasets/          # Raw CSV source files (ERP & CRM)
├── docs/              # Architecture diagrams, data flow
├── scripts/
│   ├── bronze/        # Raw ingestion scripts
│   ├── silver/        # Cleansing & transformation
│   └── gold/          # Dimensional model & fact tables
└── README.md
```

---

## 👤 About Me

I spent 20+ years in Operations and CRM — managing processes, teams and customer data across industries.
At some point I realized: the most valuable thing in any business is **understanding what the data is actually telling you**.

So I made the switch. Now I build the pipelines and models that turn raw data into decisions.

📎 [LinkedIn](https://www.linkedin.com/in/errol-d-723667a5)
📂 [Portfolio](https://github.com/SqueezeU)

---

## 📄 License

MIT License — free to use, learn from, and build upon.
