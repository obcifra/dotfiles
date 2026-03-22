---
name: "graphql-query"
description: "Research and craft optimized DRY GraphQL queries against the GitLab GraphQL API"
---

# GitLab GraphQL Query Builder

**Purpose**: Systematically research, design, and implement DRY (Don't Repeat Yourself) GraphQL queries against the GitLab GraphQL API by consulting live API documentation and applying best practices for query optimization.

## Key Principles

### DRY Query Design
- **Use fragments** to avoid repeating field selections across multiple queries or mutations
- **Compose reusable fragments** for common object structures (e.g., Issue fields, Project fields, User fields)
- **Leverage aliases** to query the same field multiple times with different arguments in a single request
- **Minimize data fetching** by requesting only necessary fields; avoid over-fetching

### Query Optimization
- **Respect complexity limits**: 200 for unauthenticated, 250 for authenticated requests
- **Use pagination properly**: Maximum page size is 100 records; use `before`/`after` cursors for traversal
- **Request complexity information**: Query `__typename` and use the `.meta` query to understand query cost
- **Consider query size limits**: Maximum 10,000 characters; use variables and fragments to reduce size
- **Batch related requests**: GitLab supports multiplex queries for efficient batching

### API Fundamentals
- **Global IDs**: Most `id` fields use GitLab Global IDs in format `"gid://gitlab/Type/number"`
- **Identifier patterns**: 
  - Projects/Groups/Namespaces use full paths (e.g., `"gitlab-org/gitlab"`)
  - Objects with IIDs use combination of full path + IID
  - Other objects use Global IDs
- **Authentication**: Requires `read_api` scope for queries, `api` scope for mutations
- **Endpoint**: `https://gitlab.com/api/graphql` (or `https://<your-gitlab>/api/graphql` for self-managed)

## Workflow

### 1. Research & Plan
**Goal**: Understand data structure and available fields before writing queries.

- [ ] Clarify the user's objective (data extraction, filtering criteria, relationship traversal)
- [ ] **Consult GitLab GraphQL Reference**: Fetch https://docs.gitlab.com/api/graphql/reference/ to identify:
  - Available root queries (e.g., `project`, `group`, `issues`)
  - Object types and their fields
  - Arguments accepted by each field
  - Deprecations and experimental flags
- [ ] **Sketch the data shape** needed as output
- [ ] **Identify reusable patterns** for fragmentation

### 2. Design Query Structure
**Goal**: Build a template that maximizes reuse and minimizes redundancy.

- [ ] **Define fragments** for commonly-repeated field selections:
  ```graphql
  fragment UserFields on User {
    id
    username
    name
    email
    state
  }
  
  fragment IssueFields on Issue {
    id
    iid
    title
    state
    author { ...UserFields }
    assignees(first: 10) {
      nodes { ...UserFields }
    }
  }
  ```
- [ ] **Plan query variables** instead of hardcoding values for:
  - Identifiers (paths, IIDs, Global IDs)
  - Pagination cursors
  - Filter arguments
- [ ] **Use aliases** if fetching the same connection multiple times:
  ```graphql
  {
    project(fullPath: "gitlab-org/gitlab") {
      openIssues: issues(state: OPENED, first: 10) { nodes { id } }
      closedIssues: issues(state: CLOSED, first: 10) { nodes { id } }
    }
  }
  ```

### 3. Build & Test
**Goal**: Validate query syntax, complexity, and correct data retrieval.

- [ ] **Start minimal**: Query only `id` and `__typename` first to verify structure
- [ ] **Incrementally add fields** to confirm field availability and response format
- [ ] **Check query complexity** by including `__typename` and comparing against published limits
- [ ] **Test with variables** using realistic values
- [ ] **Validate authentication requirements**: Verify token scope (`read_api` vs `api`)
- [ ] **Set appropriate pagination** for result sets (default first/last per field may vary)

### 4. Optimize for Reuse
**Goal**: Finalize query for maximum code reuse and maintainability.

- [ ] **Extract all constants** into variables
- [ ] **Consolidate fragments** across multiple queries
- [ ] **Document field selections**: Add comments explaining why each field is requested
- [ ] **Validate query size**: Confirm under 10,000 character limit
- [ ] **Test edge cases**: Empty results, missing fields for some objects, pagination boundaries

### 5. Implement with Authentication
**Goal**: Ready query for integration with proper security context.

- [ ] **Confirm token requirements**: Use `read_api` for queries, `api` for mutations
- [ ] **Document authentication method**:
  - Header: `Authorization: Bearer <token>`
  - Parameter: `?access_token=<token>` or `?private_token=<token>`
- [ ] **Include error handling** for 401/403 responses and rate limiting
- [ ] **Generate client code** with proper variable binding

## Common Query Patterns

### Fetch Project with Issues
```graphql
query GetProjectIssues($projectPath: ID!, $first: Int!) {
  project(fullPath: $projectPath) {
    ...ProjectDetails
    issues(first: $first, state: OPENED) {
      pageInfo { hasNextPage, endCursor }
      nodes { ...IssueDetails }
    }
  }
}

fragment ProjectDetails on Project {
  id
  name
  description
  path
  visibility
}

fragment IssueDetails on Issue {
  id
  iid
  title
  state
  author { id username }
}
```

### Fetch User & Assigned Issues
```graphql
query GetUserIssues($username: String!) {
  user(username: $username) {
    id
    name
    username
    assignedIssues(first: 50) {
      nodes { ...IssueDetails }
    }
  }
}
```

### Mutation: Create Issue
```graphql
mutation CreateIssue($projectPath: ID!, $title: String!, $description: String) {
  createIssue(input: {
    projectPath: $projectPath
    title: $title
    description: $description
  }) {
    issue { ...IssueDetails }
    errors
  }
}
```

## API Research Checklist

- [ ] GitLab GraphQL Reference: https://docs.gitlab.com/api/graphql/reference/
- [ ] GraphQL Getting Started: https://docs.gitlab.com/api/graphql/getting_started/
- [ ] Interactive GraphiQL Explorer: https://gitlab.com/-/graphql-explorer
- [ ] Query Complexity Docs: https://docs.gitlab.com/api/graphql/getting_started/#query-complexity
- [ ] Rate Limits (GitLab.com): https://docs.gitlab.com/api/
- [ ] Sample Queries: https://docs.gitlab.com/api/graphql/audit_report/ (and other examples)

## Common Pitfalls

- **Forgetting Global ID format**: Use `"gid://gitlab/Issue/123"` not just `123`
- **Exceeding complexity limits**: Test query cost before deployment
- **Over-fetching data**: Only request fields actually needed
- **Incorrect pagination**: Verify first/last/before/after boundaries per connection type
- **Token scopes**: Mutations require broader `api` scope, not just `read_api`
- **ID vs IID confusion**: IID is project-local; full path + IID needed for cross-project lookups
- **Assuming field availability**: Many fields are experimental or behind feature flags

## Maintenance

When GitLab versions change or API deprecations occur:
- Periodically check the breaking change schema: Add `?remove_deprecated=true` to endpoint
- Review deprecation notices in query responses
- Monitor the deprecation removal schedule for upcoming removals
- Update stored queries before removal dates

---

**Last Updated**: 2026-03-21  
**Reference**: GitLab GraphQL API v1 (versionless)  
**For**: Efficient, maintainable GraphQL query generation
