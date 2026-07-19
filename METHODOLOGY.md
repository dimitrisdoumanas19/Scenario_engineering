# SEGNAR — Ontology Requirements Specification & Engineering Methodology

**Ontology:** SEGNAR Domain-Independent Narrative Ontology
**IRI:** `https://w3id.org/segnar/ontology#` · **Version:** 1.0
**Document type:** Ontology Requirements Specification Document (ORSD) + engineering methodology
**Methodology:** HCOME / LLM-centered extension (SimX-HCOME+)

---

## 1. Purpose

The SEGNAR ontology provides a **domain-independent schema (TBox)** for representing the
universal narrative structure of high-stakes decision-making scenarios, so that a large language
model can be *grounded* on it: the LLM synthesises training scenarios whose entities and
relations are drawn from a knowledge graph (ABox) instantiating the schema, rather than from
unconstrained free text. The ontology is the means by which scenario generation is made
structurally consistent, traversable, and reusable across operational domains — not an end in
itself. Its purpose is therefore to make the *narrative skeleton* of a generated training
scenario — who pursues what, under which constraints, threatened by which risks, leading to
which outcomes — explicit, queryable, and reusable.

## 2. Scope

**In scope.** The generic, cross-domain anatomy of a decision-making narrative: the actors with
decision authority and the goals they pursue; the resources goals require and actors control;
the events that form causal chains and enable goals; the risks that threaten goals; the
operational, temporal, regulatory, and policy constraints on goals; the ethical and strategic
values that constrain goals and evaluate outcomes; the conflicts between goals and between
values; and the outcomes that reflect the achievement or violation of goals and values.

**Out of scope.** Domain-specific facts and taxonomies (e.g. rescue asset catalogues, border
surveillance sensor types, negotiation protocols). These are introduced by *instantiating*
SEGNAR per domain (Search-and-Rescue, Border Security, Crisis Negotiation) as domain knowledge
graphs in Neo4j. The ontology is deliberately empty of such facts so it can be reused as a
narrative-structural layer across domains without modification.

**Implementation language.** OWL 2 (serialised in Turtle). Operationalised as a labelled
property graph in Neo4j for scenario generation (see §8).

## 3. Intended uses and end-users

| Intended use | End-user |
|---|---|
| Grounding an LLM to generate structurally consistent training scenarios | AI / KG engineers |
| Constraining scenario content to entities and relations present in a domain KG | Knowledge engineers |
| Querying narrative structure (goal conflicts, risk exposure, causal chains) via competency questions (§6) | Scenario designers, trainers |
| Instantiating the narrative layer in a new operational domain | Domain modellers |
| Auditing a generated scenario against its source subgraph | Domain experts, reviewers |

## 4. Stakeholders and roles

Following HCOME, the engineering community combines three classes of human role, augmented in
this work by an LLM acting as a co-engineering agent:

- **Ontology engineers / knowledge engineers** — responsible for conceptualisation,
  formalisation, and consistency of the eight-class schema and its Neo4j realisation.
- **Domain experts** — provide and validate the narrative and decision-making knowledge for each
  evaluation domain: Search-and-Rescue, Border Security, and Crisis Negotiation; and serve as
  raters of the generated scenarios.
- **Knowledge workers / project supervisors** — frame the requirements and arbitrate consensus.

End-users (trainers and trainees consuming the generated scenarios) are stakeholders of the
*product* rather than the engineering process, but their needs drive the non-functional
requirements (realism, consistency, pedagogical value).

## 5. Non-functional requirements

1. **Domain independence** — no class or property shall presuppose a single application domain;
   the schema was reused across all three evaluation domains without structural modification.
2. **Narrative completeness** — the schema must be able to carry a full scenario skeleton:
   actors, goals, resources, events, risks, constraints, values, and outcomes, with the
   conflicts and causal links between them.
3. **Graph-operational** — every class and relationship must map cleanly to a Neo4j node label
   or typed relationship, so scenario generation can be driven by Cypher traversal (§8).
4. **Reusability & FAIR** — resolvable IRI (`w3id.org/segnar/ontology`), versioned, documented,
   and openly licensed (CC BY 4.0).
5. **LLM-friendliness** — labels and definitions written so a language model can instantiate the
   schema and consume subgraphs serialised from it with low ambiguity.

## 6. Functional requirements — Competency Questions (CQs)

The functional requirements are expressed as competency questions, grouped thematically. Each CQ
is answerable by traversing the indicated terms; together they were used to drive and to test
the conceptualisation, and each is answerable through Cypher queries over the instantiated
domain graphs.

**T1 · Actors, Goals & Resources**
- CQ1.1 Which goals does a given actor pursue? — `Actor`, `pursues`, `Goal`
- CQ1.2 Which resources does a goal require, and which actor possesses them? — `requires`, `possesses`, `Resource`
- CQ1.3 Which goals require a resource that is scarce or consumable? — `requires`, `quantity`, `consumable`
- CQ1.4 What is the priority of each goal in a scenario? — `priority`

**T2 · Conflict**
- CQ2.1 Which goals conflict with a given goal, and do they share required resources? — `conflictsWith`, `requires`
- CQ2.2 Which values conflict with each other in a given decision point? — `Value`, `conflictsWith`
- CQ2.3 How intense is a given goal or value conflict, and of what type is it? — `conflictIntensity`, CONFLICTS (`conflict_type`)
- CQ2.4 Which values constrain the goals involved in a given decision point? — `Value`, `constrains`, `Goal`

**T3 · Risk**
- CQ3.1 Which risks threaten the goals pursued by a given actor? — `Risk`, `threatens`, `pursues`
- CQ3.2 What is the risk score of a given risk? — `riskScore`
- CQ3.3 Which resources mitigate a given risk? — `mitigates`

**T4 · Events, Causality & Outcomes**
- CQ4.1 Which causal chains of events unfold in a scenario? — `Event`, `causes`, `timestamp`
- CQ4.2 Which events enable a given goal? — `enables`
- CQ4.3 Which outcomes does a sequence of events achieve? — `achieves`, `Outcome`
- CQ4.4 Against which values is an outcome evaluated? — `evaluates`

**T5 · Constraints**
- CQ5.1 Which constraints limit a given goal, and of what kind (operational, temporal,
  regulatory, policy)? — `Constraint`, `constrains`

**Cross-cutting (the paper's headline requirements)**
- CQ-A Can a coherent scenario skeleton (actors → goals → conflicts → risks → events → outcomes)
  be extracted as a connected subgraph for any decision point in any domain?
- CQ-B Does grounding scenario generation on SEGNAR subgraphs improve structural consistency and
  domain fidelity versus ungrounded generation?

### Cardinality constraints

The core relationship constraints specified with the schema: an `Actor` pursues **one or more**
`Goal`s; a `Goal` requires **zero or more** `Resource`s; a `Risk` threatens **one or more**
`Goal`s; an `Event` causes **zero or more** `Event`s; a `Value` constrains **zero or more**
`Goal`s.

## 7. Engineering methodology

### 7.1 Why HCOME

The SEGNAR ontology was engineered with the **Human-Centered Ontology Engineering Methodology
(HCOME)** (Kotis & Vouros, 2006), chosen because it is human-centred, collaborative, and
iterative; it treats ontologies as *living* artefacts under continuous evolution; and it gives
domain experts — not only engineers — an active role in shaping the conceptualisation. These
properties matter here because the narrative and decision-making knowledge is owned by
operational experts, and because the ontology must keep evolving as it is exercised across
domains.

### 7.2 Spaces

HCOME organises work into a **personal space**, where an individual develops, imports, and
improves a conceptualisation, and a **shared space**, where versions are inspected, compared,
criticised through argumentation, and agreed. The SEGNAR schema moved repeatedly between the
two.

### 7.3 Phase 1 — Specification

Requirements, scope (§2), intended uses and end-users (§3), and the competency questions (§6)
were elicited from operational training scenarios in the three evaluation domains. The output of
this phase is, essentially, sections 1–6 of this document.

### 7.4 Phase 2 — Conceptualization

In personal space, the engineer produced successive versions of the eight-class schema. HCOME's
*data-driven (bottom-up)* conceptualisation (Kotis & Papasalouros, 2010) was applied by seeding
concepts from real operational scenario material in the three domains and lifting the recurring
narrative pattern — actors pursuing conflicting goals over scarce resources, under constraints
and values, threatened by risks, driven by causal event chains toward outcomes — into the
schema. An LLM (Claude Sonnet 4.5) participated as a co-engineering agent in drafting and
refining the conceptualisation and in constructing the domain knowledge graphs that instantiate
it, with the human engineer and domain experts retaining review and consensus authority
(SimX-HCOME+). Versions were detailed, compared, and merged.

### 7.4.1 Reused vocabularies

SEGNAR follows the HCOME principle of *reuse before reinvention*, applied here at the
**annotation and metadata level** (vocabularies used to describe and document the ontology, not
to extend the domain model):

| Vocabulary | IRI | Used for |
|---|---|---|
| **Dublin Core Terms (DCMI)** | `http://purl.org/dc/terms/` | Ontology metadata: title, description, creator, publisher, license. |
| **VANN** | `http://purl.org/vocab/vann/` | Vocabulary-documentation hints: preferred namespace prefix and URI. |

**Foundational languages** (the representation languages, listed for completeness rather than as
domain reuse): RDF, RDFS, OWL 2, and XSD datatypes.

No domain or upper ontologies are imported. SEGNAR intentionally does **not** reuse a heavy
foundational ontology (e.g. DOLCE, BFO) so that it stays lightweight, LLM-friendly, and directly
mappable to a labelled property graph; alignment to an upper ontology (or to the authors' CDMO
decision-making layer) is left as optional future work. The ontology is self-contained and easy
to load.

### 7.5 Phase 3 — Exploitation & Evaluation

In shared space, candidate versions were inspected and criticised through argumentation
(IBIS-style issues / positions / arguments), and consensus was reached before a version was
promoted to "agreed". Evaluation activities are detailed in §9. The agreed v1.0 is the artefact
published here.

## 8. Operationalisation in Neo4j

The ontology is realised as a labelled property graph. Each ontology class maps to a Neo4j node
label and each ontology relationship to a typed Neo4j relationship:

| Ontology term | Neo4j realisation |
|---|---|
| `segnar:Actor` … `segnar:Outcome` (8 classes) | Node labels `Actor`, `Goal`, `Resource`, `Event`, `Risk`, `Constraint`, `Value`, `Outcome` |
| `segnar:pursues` | `PURSUES` |
| `segnar:requires` | `REQUIRES` |
| `segnar:possesses` | `POSSESSES` |
| `segnar:threatens` | `THREATENS` |
| `segnar:causes` | `CAUSES` |
| `segnar:enables` | `ENABLES` |
| `segnar:conflictsWith` | `CONFLICTS` (carrying `conflict_type`, `conflict_intensity`) |
| `segnar:constrains` | `CONSTRAINS` |
| `segnar:mitigates` | `MITIGATES` |
| `segnar:achieves` | `ACHIEVES` |
| `segnar:evaluates` | `EVALUATES` |

Datatype properties are realised as node/relationship properties (per-class identifiers such as
`actor_id`, `goal_id`; `name`; `priority`; `risk_score` and `conflict_intensity` in [0,1];
`quantity`; `consumable`; `timestamp`). Domain-specific attribute sets and additional
relationship types are instantiated per domain during knowledge graph construction, on top of
this invariant structural core.

## 9. Evaluation

The SEGNAR ontology and its instances were evaluated by:

1. **Competency-question coverage** — every CQ in §6 is answerable through Cypher queries over
   the instantiated domain graphs.
2. **Cross-domain reuse without modification** — the same TBox was instantiated for
   Search-and-Rescue, Border Security, and Crisis Negotiation without structural change,
   confirming domain independence.
3. **Reasoner consistency** — the TBox is logically consistent (no unsatisfiable classes).
4. **Expert review** — domain experts inspected the schema and the instantiated graphs in
   shared-space argumentation.
5. **Empirical task evaluation** — KG-grounded scenario generation on SEGNAR subgraphs versus
   ungrounded baselines, across the three domains, scored by domain experts on a
   multi-dimensional quality rubric (the subject of the paper).

## 10. Maintenance and versioning

The SEGNAR ontology is a *living* ontology. Versions are tracked in the repository
(`https://github.com/dimitrisdoumanas19/Scenario_engineering`); the current published version is
1.0. Feedback from exploitation — deficiencies surfaced by expert scoring of generated
scenarios — feeds the next specification cycle, closing the HCOME loop.

## References

- Kotis, K., & Vouros, G. A. (2006). *Human-centered ontology engineering: The HCOME
  methodology.* Knowledge and Information Systems, 10(1), 109–131.
  https://doi.org/10.1007/s10115-005-0227-4
- Kotis, K., & Papasalouros, A. (2010). *Learning useful kick-off ontologies from query logs:
  HCOME revised.* 2010 International Conference on Complex, Intelligent and Software Intensive
  Systems.
- DCMI. *Dublin Core Metadata Terms.*
  https://www.dublincore.org/specifications/dublin-core/dcmi-terms/
- VANN: *A vocabulary for annotating vocabulary descriptions.* https://vocab.org/vann/
