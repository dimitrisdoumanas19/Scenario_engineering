# SEGNAR: Scenario Engineering with Generative Narratives and Reasoning

Supplementary material for the paper *SEGNAR: A Generalizable Scenario-Generation Framework Combining Knowledge Graphs and LLMs for Complex Decision Making Training*, submitted to ACM Transactions on Intelligent Systems and Technology (Special Issue on New Frontiers in Interactive Storytelling and Computational Models of Narrative).

**Authors:** Dimitrios Doumanas, Konstantinos Kotis
**Affiliation:** Intelligent Systems Lab, Department of Cultural Technology and Communication, University of the Aegean

## Overview

SEGNAR is a hybrid symbolic-neural framework that generates structured training scenarios for high-stakes decision-making domains. A domain-independent narrative ontology is instantiated into domain-specific knowledge graphs (Neo4j), which are supplied as generation context to a large language model that produces scenarios in a fixed 14-section template. Generated scenarios are then verified programmatically against the graph data and evaluated by domain experts on a six-dimensional, 100-point rubric.

The framework is demonstrated in three domains, Search and Rescue (SAR), Border Security, and Crisis Negotiation, with 10 scenarios per domain (30 total), plus an ablation study comparing generation with and without knowledge graph grounding.

## Repository structure

```
.
├── SEGNAR_ontology.ttl                # OWL 2 ontology (Turtle)
├── SEGNAR_competency_questions.md     # Competency questions with Cypher formalizations
├── ontology engineering prompt.rtf    # Prompt: ontology design
├── KG engineering prompt.rtf          # Prompt: knowledge graph construction
├── scenario generation prompt.rtf     # Prompt: KG-grounded scenario synthesis
├── framework.png                      # Pipeline overview (Figure 1)
├── Search and Rescue/
├── Border_Security/
├── NEGOTIATION/
├── ablation/
├── LICENSE
└── README.md
```

### Domain folders

Each domain folder (`Search and Rescue/`, `Border_Security/`, `NEGOTIATION/`) contains the same artifact set:

- `CSV files/` — the exported knowledge graph datasets: one CSV per entity type (actors, goals, resources, events, risks, constraints, values, outcomes) and one per relationship type (pursues, requires, conflicts, causes, threatens, enables, mitigates, constrains, possesses, achieves, prioritizes, depletes, assigned_to, and the domain-specific relationships).
- `FINAL_neo4j_import.cypher` — Neo4j import script that loads the CSV files into the graph.
- the generated training scenarios (`… SCENARIOS.rtf` and `scenarios generation.docx`) — the 10 scenarios for that domain and the full LLM generation transcript.
- `*_scenario_evaluation_complete.xlsx` — the per-scenario six-dimensional rubric scores.
- `*_scenario_evaluation_report.md` — the evaluation report for that domain.

### Ablation study (`ablation/`)

The no-KG condition artifacts:

- `Ablation_Prompt_NoKG.txt` — the ablation prompt (identical task, no knowledge graph attached).
- `ablation SAR GPT5.2.docx`, `ablation Border Security GPT5.2.docx`, `ablation Crisis Negotiation GPT5.2.docx` — the six generated no-KG scenarios (two per domain) with transcripts.
- `Ablation_Expert_Scoring_Sheet.xlsx` — the expert scoring sheet (D2, D3, D4, D6.2).
- `expert evaluation.docx` — the expert evaluation notes.
- `Ablation_Scoring_Workbook.xlsx` — the KG vs no-KG comparison workbook.
- `Ablation_Final_Analysis.md` — the full comparative analysis.

## Models and settings

- Ontology engineering and knowledge graph construction: Claude Sonnet 4.5
- Scenario generation: GPT-5.2 (extended thinking)
- Generation settings were held constant across all three domains.

## Reproducing the pipeline

1. **Ontology.** Use `SEGNAR_ontology.ttl`, or run `ontology engineering prompt.rtf`.
2. **Knowledge graph.** Run `KG engineering prompt.rtf` with the ontology for the target domain; the model outputs the CSV datasets.
3. **Import.** Load the `CSV files/` into Neo4j with `FINAL_neo4j_import.cypher`.
4. **Scenario generation.** Run `scenario generation prompt.rtf` with the graph and CSVs attached as context.
5. **Verification.** Validate entity identifiers, relationships, and numeric parameters against the CSV files, and execute each scenario's evidence queries against the Neo4j instance.
6. **Evaluation.** Score scenarios with the six-dimensional rubric (defined in the paper; per-domain scoring workbooks are in each domain folder).

## Ontology

The domain-independent narrative ontology (eight classes: Actor, Goal, Resource, Event, Risk, Constraint, Value, Outcome) is provided as `SEGNAR_ontology.ttl` (OWL 2, Turtle), with its competency questions and Cypher formalizations in `SEGNAR_competency_questions.md`. The mapping between ontology classes/relationships and their Neo4j realization is documented in the paper (Section 3.1).

## License

Code and Cypher queries are released under the MIT License. Scenario texts, transcripts, datasets, the ontology, and documentation are released under CC BY 4.0. See the LICENSE file.

## Citation

```
Dimitrios Doumanas and Konstantinos Kotis. 2026. SEGNAR: A Generalizable
Scenario-Generation Framework Combining Knowledge Graphs and LLMs for Complex
Decision Making Training. ACM Trans. Intell. Syst. Technol.
```

## Contact

Dimitrios Doumanas — doumanas@aegean.gr
