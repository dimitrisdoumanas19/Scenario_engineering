// ============================================================================
// SEGNAR KNOWLEDGE GRAPH - NEO4J IMPORT SCRIPT
// Generated from CSV dataset
// Total Nodes: 94 | Total Relationships: 346
// ============================================================================

// Clear existing data (WARNING: This deletes all data!)
MATCH (n) DETACH DELETE n;

// Create constraints for performance and uniqueness
CREATE CONSTRAINT actor_id_unique IF NOT EXISTS FOR (a:Actor) REQUIRE a.actor_id IS UNIQUE;
CREATE CONSTRAINT goal_id_unique IF NOT EXISTS FOR (g:Goal) REQUIRE g.goal_id IS UNIQUE;
CREATE CONSTRAINT resource_id_unique IF NOT EXISTS FOR (r:Resource) REQUIRE r.resource_id IS UNIQUE;
CREATE CONSTRAINT event_id_unique IF NOT EXISTS FOR (e:Event) REQUIRE e.event_id IS UNIQUE;
CREATE CONSTRAINT risk_id_unique IF NOT EXISTS FOR (rk:Risk) REQUIRE rk.risk_id IS UNIQUE;
CREATE CONSTRAINT constraint_id_unique IF NOT EXISTS FOR (c:Constraint) REQUIRE c.constraint_id IS UNIQUE;
CREATE CONSTRAINT value_id_unique IF NOT EXISTS FOR (v:Value) REQUIRE v.value_id IS UNIQUE;
CREATE CONSTRAINT outcome_id_unique IF NOT EXISTS FOR (o:Outcome) REQUIRE o.outcome_id IS UNIQUE;

// ============================================================================
// LOAD ENTITY NODES FROM CSV
// ============================================================================

// Load Actor nodes (10 nodes)
LOAD CSV WITH HEADERS FROM 'file:///actors.csv' AS row
CREATE (a:Actor {
  actor_id: row.actor_id,
  name: row.name,
  role: row.role,
  authority_level: toInteger(row.authority_level),
  expertise: split(row.expertise, '|'),
  emotional_state: row.emotional_state,
  availability: toFloat(row.availability),
  location: row.location,
  team_affiliation: row.team_affiliation,
  communication_channels: split(row.communication_channels, '|')
});

// Load Goal nodes (10 nodes)
LOAD CSV WITH HEADERS FROM 'file:///goals.csv' AS row
CREATE (g:Goal {
  goal_id: row.goal_id,
  name: row.name,
  priority: row.priority,
  status: row.status,
  success_criteria: split(row.success_criteria, '|'),
  deadline: row.deadline,
  measurable_target: CASE WHEN row.measurable_target IS NULL OR row.measurable_target = '' THEN null ELSE toFloat(row.measurable_target) END,
  current_progress: toFloat(row.current_progress),
  parent_goal: CASE WHEN row.parent_goal IS NULL OR row.parent_goal = '' THEN null ELSE row.parent_goal END,
  failure_consequences: CASE WHEN row.failure_consequences IS NULL OR row.failure_consequences = '' THEN [] ELSE split(row.failure_consequences, '|') END
});

// Load Resource nodes (15 nodes)
LOAD CSV WITH HEADERS FROM 'file:///resources.csv' AS row
CREATE (r:Resource {
  resource_id: row.resource_id,
  name: row.name,
  type: row.type,
  quantity: toFloat(row.quantity),
  unit: row.unit,
  consumption_rate: CASE WHEN row.consumption_rate IS NULL OR row.consumption_rate = '' THEN null ELSE toFloat(row.consumption_rate) END,
  replenishable: toBoolean(row.replenishable),
  criticality: row.criticality,
  location: row.location,
  access_restrictions: CASE WHEN row.access_restrictions IS NULL OR row.access_restrictions = '' THEN [] ELSE split(row.access_restrictions, '|') END
});

// Load Event nodes (15 nodes)
LOAD CSV WITH HEADERS FROM 'file:///events.csv' AS row
CREATE (e:Event {
  event_id: row.event_id,
  name: row.name,
  type: row.type,
  timestamp: row.timestamp,
  duration: CASE WHEN row.duration IS NULL OR row.duration = '' THEN null ELSE toFloat(row.duration) END,
  probability: CASE WHEN row.probability IS NULL OR row.probability = '' THEN null ELSE toFloat(row.probability) END,
  impact_magnitude: toFloat(row.impact_magnitude),
  reversible: toBoolean(row.reversible),
  triggered_by: CASE WHEN row.triggered_by IS NULL OR row.triggered_by = '' THEN null ELSE row.triggered_by END,
  state_changes: split(row.state_changes, '|')
});

// Load Risk nodes (12 nodes)
LOAD CSV WITH HEADERS FROM 'file:///risks.csv' AS row
CREATE (rk:Risk {
  risk_id: row.risk_id,
  name: row.name,
  category: row.category,
  severity: row.severity,
  likelihood: row.likelihood,
  risk_score: toFloat(row.risk_score),
  time_horizon: row.time_horizon,
  affected_entities: split(row.affected_entities, '|'),
  mitigation_strategies: split(row.mitigation_strategies, '|'),
  current_status: row.current_status
});

// Load Constraint nodes (12 nodes)
LOAD CSV WITH HEADERS FROM 'file:///constraints.csv' AS row
CREATE (c:Constraint {
  constraint_id: row.constraint_id,
  name: row.name,
  type: row.type,
  enforcement: row.enforcement,
  scope: split(row.scope, '|'),
  condition: row.condition,
  violation_consequence: CASE WHEN row.violation_consequence IS NULL OR row.violation_consequence = '' THEN null ELSE row.violation_consequence END,
  flexibility: toFloat(row.flexibility),
  origin: CASE WHEN row.origin IS NULL OR row.origin = '' THEN null ELSE row.origin END,
  active_period: CASE WHEN row.active_period IS NULL OR row.active_period = '' THEN null ELSE row.active_period END
});

// Load Value nodes (10 nodes)
LOAD CSV WITH HEADERS FROM 'file:///values.csv' AS row
CREATE (v:Value {
  value_id: row.value_id,
  name: row.name,
  category: row.category,
  priority_weight: toFloat(row.priority_weight),
  description: row.description,
  stakeholders: split(row.stakeholders, '|'),
  measurable_indicators: CASE WHEN row.measurable_indicators IS NULL OR row.measurable_indicators = '' THEN [] ELSE split(row.measurable_indicators, '|') END,
  conflicts_with: CASE WHEN row.conflicts_with IS NULL OR row.conflicts_with = '' THEN [] ELSE split(row.conflicts_with, '|') END,
  cultural_context: CASE WHEN row.cultural_context IS NULL OR row.cultural_context = '' THEN null ELSE row.cultural_context END,
  tradeable: toBoolean(row.tradeable)
});

// Load Outcome nodes (10 nodes)
LOAD CSV WITH HEADERS FROM 'file:///outcomes.csv' AS row
CREATE (o:Outcome {
  outcome_id: row.outcome_id,
  name: row.name,
  type: row.type,
  achievement_level: toFloat(row.achievement_level),
  associated_goals: split(row.associated_goals, '|'),
  metrics: row.metrics,
  value_alignment: split(row.value_alignment, '|'),
  contributing_events: split(row.contributing_events, '|'),
  lessons_learned: CASE WHEN row.lessons_learned IS NULL OR row.lessons_learned = '' THEN [] ELSE split(row.lessons_learned, '|') END,
  timestamp: row.timestamp
});

// ============================================================================
// LOAD RELATIONSHIPS FROM CSV
// ============================================================================

// Create PURSUES relationships (Actor → Goal) - 19 edges
LOAD CSV WITH HEADERS FROM 'file:///pursues.csv' AS row
MATCH (a:Actor {actor_id: row.source_actor_id})
MATCH (g:Goal {goal_id: row.target_goal_id})
CREATE (a)-[:PURSUES {
  commitment_strength: toFloat(row.commitment_strength),
  start_time: row.start_time,
  resources_allocated: CASE WHEN row.resources_allocated IS NULL OR row.resources_allocated = '' THEN [] ELSE split(row.resources_allocated, '|') END
}]->(g);

// Create REQUIRES relationships (Goal → Resource) - 26 edges
LOAD CSV WITH HEADERS FROM 'file:///requires.csv' AS row
MATCH (g:Goal {goal_id: row.source_goal_id})
MATCH (r:Resource {resource_id: row.target_resource_id})
CREATE (g)-[:REQUIRES {
  quantity_needed: toFloat(row.quantity_needed),
  criticality: row.criticality
}]->(r);

// Create POSSESSES relationships (Actor → Resource) - 41 edges
LOAD CSV WITH HEADERS FROM 'file:///possesses.csv' AS row
MATCH (a:Actor {actor_id: row.source_actor_id})
MATCH (r:Resource {resource_id: row.target_resource_id})
CREATE (a)-[:POSSESSES {
  quantity_held: toFloat(row.quantity_held),
  access_level: row.access_level
}]->(r);

// Create THREATENS relationships (Risk → Entity) - 31 edges
LOAD CSV WITH HEADERS FROM 'file:///threatens.csv' AS row
MATCH (rk:Risk {risk_id: row.source_risk_id})
MATCH (target)
WHERE (target:Actor AND target.actor_id = row.target_entity_id)
   OR (target:Goal AND target.goal_id = row.target_entity_id)
   OR (target:Resource AND target.resource_id = row.target_entity_id)
   OR (target:Event AND target.event_id = row.target_entity_id)
CREATE (rk)-[:THREATENS {
  threat_level: toFloat(row.threat_level),
  exposure_window: row.exposure_window
}]->(target);

// Create CONSTRAINS relationships (Constraint → Entity) - 36 edges
LOAD CSV WITH HEADERS FROM 'file:///constrains.csv' AS row
MATCH (c:Constraint {constraint_id: row.source_constraint_id})
MATCH (target)
WHERE (target:Actor AND target.actor_id = row.target_entity_id)
   OR (target:Goal AND target.goal_id = row.target_entity_id)
   OR (target:Resource AND target.resource_id = row.target_entity_id)
   OR (target:Event AND target.event_id = row.target_entity_id)
CREATE (c)-[:CONSTRAINS {
  restriction_type: row.restriction_type,
  severity: toFloat(row.severity)
}]->(target);

// Create ENABLES relationships (Resource/Event → Event/Goal) - 32 edges
LOAD CSV WITH HEADERS FROM 'file:///enables.csv' AS row
MATCH (source)
WHERE (source:Resource AND source.resource_id = row.source_entity_id)
   OR (source:Event AND source.event_id = row.source_entity_id)
MATCH (target)
WHERE (target:Event AND target.event_id = row.target_entity_id)
   OR (target:Goal AND target.goal_id = row.target_entity_id)
CREATE (source)-[:ENABLES {
  enablement_strength: toFloat(row.enablement_strength),
  required: toBoolean(row.required)
}]->(target);

// Create CAUSES relationships (Event → Event/Outcome) - 23 edges
LOAD CSV WITH HEADERS FROM 'file:///causes.csv' AS row
MATCH (e:Event {event_id: row.source_event_id})
MATCH (target)
WHERE (target:Event AND target.event_id = row.target_entity_id)
   OR (target:Outcome AND target.outcome_id = row.target_entity_id)
   OR (target:Goal AND target.goal_id = row.target_entity_id)
   OR (target:Risk AND target.risk_id = row.target_entity_id)
CREATE (e)-[:CAUSES {
  causality_strength: toFloat(row.causality_strength),
  time_delay: CASE WHEN row.time_delay IS NULL OR row.time_delay = '' THEN null ELSE toFloat(row.time_delay) END,
  probability: CASE WHEN row.probability IS NULL OR row.probability = '' THEN null ELSE toFloat(row.probability) END
}]->(target);

// Create CONFLICTS relationships (Goal ↔ Goal) - 10 edges
LOAD CSV WITH HEADERS FROM 'file:///conflicts.csv' AS row
MATCH (g1:Goal {goal_id: row.source_goal_id})
MATCH (g2:Goal {goal_id: row.target_goal_id})
CREATE (g1)-[:CONFLICTS {
  conflict_intensity: toFloat(row.conflict_intensity),
  conflict_type: row.conflict_type
}]->(g2);

// Create MITIGATES relationships (Event/Resource/Actor → Risk) - 23 edges
LOAD CSV WITH HEADERS FROM 'file:///mitigates.csv' AS row
MATCH (source)
WHERE (source:Event AND source.event_id = row.source_entity_id)
   OR (source:Resource AND source.resource_id = row.source_entity_id)
   OR (source:Actor AND source.actor_id = row.source_entity_id)
MATCH (rk:Risk {risk_id: row.target_risk_id})
CREATE (source)-[:MITIGATES {
  mitigation_effectiveness: toFloat(row.mitigation_effectiveness),
  mitigation_type: row.mitigation_type
}]->(rk);

// Create VIOLATES relationships (Event/Actor → Value/Constraint) - 3 edges
LOAD CSV WITH HEADERS FROM 'file:///violates.csv' AS row
MATCH (source)
WHERE (source:Event AND source.event_id = row.source_entity_id)
   OR (source:Actor AND source.actor_id = row.source_entity_id)
MATCH (target)
WHERE (target:Value AND target.value_id = row.target_entity_id)
   OR (target:Constraint AND target.constraint_id = row.target_entity_id)
CREATE (source)-[:VIOLATES {
  violation_severity: toFloat(row.violation_severity),
  intentional: toBoolean(row.intentional)
}]->(target);

// Create SUPPORTS relationships (Value → Goal/Event) - 31 edges
LOAD CSV WITH HEADERS FROM 'file:///supports.csv' AS row
MATCH (v:Value {value_id: row.source_value_id})
MATCH (target)
WHERE (target:Goal AND target.goal_id = row.target_entity_id)
   OR (target:Event AND target.event_id = row.target_entity_id)
CREATE (v)-[:SUPPORTS {
  alignment_strength: toFloat(row.alignment_strength)
}]->(target);

// Create ACHIEVES relationships (Event → Goal) - 10 edges
LOAD CSV WITH HEADERS FROM 'file:///achieves.csv' AS row
MATCH (e:Event {event_id: row.source_event_id})
MATCH (g:Goal {goal_id: row.target_goal_id})
CREATE (e)-[:ACHIEVES {
  completion_percentage: toFloat(row.completion_percentage)
}]->(g);

// Create DEPLETES relationships (Event → Resource) - 12 edges
LOAD CSV WITH HEADERS FROM 'file:///depletes.csv' AS row
MATCH (e:Event {event_id: row.source_event_id})
MATCH (r:Resource {resource_id: row.target_resource_id})
CREATE (e)-[:DEPLETES {
  depletion_amount: toFloat(row.depletion_amount),
  depletion_rate: toFloat(row.depletion_rate)
}]->(r);

// Create ASSIGNED_TO relationships (Goal/Resource → Actor) - 17 edges
LOAD CSV WITH HEADERS FROM 'file:///assigned_to.csv' AS row
MATCH (source)
WHERE (source:Goal AND source.goal_id = row.source_entity_id)
   OR (source:Resource AND source.resource_id = row.source_entity_id)
MATCH (a:Actor {actor_id: row.target_actor_id})
CREATE (source)-[:ASSIGNED_TO {
  assignment_timestamp: row.assignment_timestamp,
  authority_granted: toBoolean(row.authority_granted)
}]->(a);

// Create PRIORITIZES relationships (Actor → Value) - 32 edges
LOAD CSV WITH HEADERS FROM 'file:///prioritizes.csv' AS row
MATCH (a:Actor {actor_id: row.source_actor_id})
MATCH (v:Value {value_id: row.target_value_id})
CREATE (a)-[:PRIORITIZES {
  priority_rank: toInteger(row.priority_rank)
}]->(v);

// ============================================================================
// VERIFY GRAPH STATISTICS
// ============================================================================

// Count nodes by label
MATCH (n) RETURN labels(n)[0] as NodeType, count(n) as Count ORDER BY Count DESC;

// Count relationships by type
MATCH ()-[r]->() RETURN type(r) as RelationshipType, count(r) as Count ORDER BY Count DESC;

// Total graph size
MATCH (n) WITH count(n) as NodeCount
MATCH ()-[r]->() WITH NodeCount, count(r) as RelCount
RETURN NodeCount, RelCount, (NodeCount + RelCount) as TotalElements;
