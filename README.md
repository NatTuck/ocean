
# Steno

Steno is a web service that provides sandboxed autograding for programming
assignments.

The basic flow is as follows:

 * Caller POSTs a job to an API endpoint.
   * Task includes a full description of the autograding job.
   * This description includes stuff like the URL of the code
     to be run, the sandbox config, etc.
   * POST is authenticated by shared-key JWT.
 * Steno adds job to queue.
   * One queue, shared across workers.
 * Worker pulls job off queue and runs it:
   * Create appropriate sandbox container.
   * Run job script.
   * Collect output.
 * Steno POSTs output to postback URL provided in job.
   * POST is identified by caller-provided metadata.
   * POST is authenticated by shared-key JWT

Steno is designed to be deployed in a cluster config with every node acting both
as a job runner and as an HTTP server. A steno cluster should live behind a
reverse proxy / load balancer with a single host name.


## Grading Job Data

 - key: string (e.g. "asg_id,sub_id"), should be unique
 - user: string, for display
 - desc: string, for display
 - sbx_cfg: json_map
 - sub_url: string
 - gra_url: string
 - meta: json_map

## Grading Complete Data

 - key: string
 - meta: json_map
 - output: json_map
