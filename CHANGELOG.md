## 2.0.2
  - workaround failing test by forcing text out of event.sprintf to be
    always in UTF-8, when this is fix in logstash-core the changes could
    removed.

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

