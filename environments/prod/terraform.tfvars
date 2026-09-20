project_id  = "myapp-prod-123456" # must match bootstrap prod_project_id
region      = "us-east1"
app_name    = "myapp"
github_repo = "myorg/myapp-infra" # repo that builds/deploys the app

developer_members = ["group:myapp-devs@example.com"]
admin_members     = ["group:myapp-admins@example.com"]

enable_bigtable = true

# bigtable_tables = { events = { column_families = ["cf1"] } }
# scheduler_jobs  = { nightly-cleanup = { schedule = "0 3 * * *", path = "/tasks/cleanup" } }
