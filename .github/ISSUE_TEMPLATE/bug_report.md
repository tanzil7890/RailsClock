---
name: Bug report
about: Create a report to help us improve RailsClocks
title: '[BUG] '
labels: bug
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Configure RailsClocks with settings: ...
2. Make a request to endpoint '...'
3. Try to replay the request with '...'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Actual behavior**
A clear and concise description of what actually happened.

**Environment (please complete the following information):**
 - Ruby version: [e.g. 3.2.0]
 - Rails version: [e.g. 7.0.4]
 - RailsClocks version: [e.g. 0.1.0]
 - Database being used: [e.g. PostgreSQL 14]
 - Operating System: [e.g. Ubuntu 22.04]

**RailsClocks Configuration**
```ruby
# Please paste your RailsClocks configuration here
RailsClocks.configure do |config|
  config.enabled = true
  config.sample_rate = 1.0
  # etc...
end
```

**Relevant Request Data**
```ruby
# If applicable, paste the relevant recorded request data
# You can find this using:
RailsClocks::RecordedRequest.find_by(uuid: 'your-request-uuid').attributes
```

**Error Output**
```
If applicable, paste any error messages or stack traces here
```

**Additional context**
- Are you using any specific middleware that might interfere with request recording?
- Have you modified any of the default RailsClocks settings?
- Are you using any custom configurations for request filtering?
- Is this happening in development, test, or production environment?

**Logs**
```
Please include relevant sections of your Rails logs showing the issue
```

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Possible Solution**
If you have any ideas about what might be causing the issue or how to fix it, please share them here.

**Related Issues**
Are there any related issues or pull requests you're aware of? Please link them here.

---

**Checklist:**
- [ ] I have checked that this issue hasn't already been reported
- [ ] I have included all the required information above
- [ ] I have included the RailsClocks configuration
- [ ] I have included relevant error messages and logs
- [ ] I am using the latest version of RailsClocks