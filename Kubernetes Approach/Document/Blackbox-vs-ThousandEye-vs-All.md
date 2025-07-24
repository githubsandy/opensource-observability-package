# 📘 Blackbox Exporter: Evaluation and Comparison for Open Source Full Stack Monitoring

## 🧩 Context

We are building a **self-contained, open-source full-stack observability package** including:

* Prometheus
* Grafana
* Loki
* Promtail
* Node Exporter

We aim to include a reliable **network monitoring** component. We evaluated multiple tools and have found **Blackbox Exporter** to be a potentially suitable candidate. Below is a detailed evaluation, comparison, and justification.

---

## ✅ Why Blackbox Exporter?

Blackbox Exporter fits naturally with Prometheus and Grafana ecosystems. It enables:

* HTTP/HTTPS probe checks
* ICMP (ping) monitoring
* TCP port availability
* DNS resolution checks

It exports these metrics in a Prometheus-compatible format, allowing alerting, visualization, and historical tracking via Grafana dashboards.

---

## 🔍 Comparison with Other Tools

| Feature / Use Case              | ThousandEyes                         | Blackbox Exporter                      | Pingmesh                              | SmokePing                            | Fit in Your Stack?                          |
|--------------------------------|--------------------------------------|----------------------------------------|----------------------------------------|-------------------------------------|---------------------------------------------|
| ICMP Ping Monitoring           | ✅ Global & local agents             | ✅ Yes                                  | ✅ Yes                                  | ✅ Yes                              | ✅ Blackbox, Pingmesh, SmokePing             |
| HTTP/HTTPS Monitoring          | ✅ TLS, headers, page load           | ✅ Basic GET/HEAD/SSL                   | ❌                                      | ✅ Basic with effort                | ✅ Blackbox Exporter                         |
| DNS Resolution Checks          | ✅ Advanced DNS views                | ✅ Simple checks                         | ❌                                      | ✅ Basic checks                     | ✅ Blackbox Exporter                         |
| TCP Port Checks                | ✅ Smart port availability           | ✅ Yes                                  | ❌                                      | ⚠️ Needs config                    | ✅ Blackbox Exporter                         |
| Traceroute / Path Tracing      | ✅ BGP-aware path tracing           | ❌                                      | ✅ Limited traceroute                   | ❌                                  | ⚠️ External tool needed (e.g. `scamper`)     |
| Jitter / Latency Graphing      | ✅ Visual + baseline deviation      | ❌ (RTT only)                           | ✅ Good internal metrics                | ✅ Very strong                      | ✅ Pingmesh or SmokePing                     |
| Packet Loss Detection          | ✅ Layered packet loss visibility   | ⚠️ Manual RTT trends                   | ✅ Yes                                  | ✅ Yes                              | ✅ Pingmesh or SmokePing                     |
| BGP / Routing Intelligence     | ✅ Internet-wide view               | ❌                                      | ❌                                      | ❌                                  | ❌ Not needed for internal stack             |
| Global Agent Coverage          | ✅ Cloud + private                  | ❌ Self-hosted only                     | ❌ Self-hosted only                     | ❌ Self-hosted only                 | ✅ Stack supports local agents               |
| Custom Probe Frequency         | ✅ Down to 2 min                    | ✅ Yes                                  | ✅ Yes                                  | ✅ Yes                              | ✅ All support flexible intervals            |
| Dashboard / UI                 | ✅ Native & rich                    | ⚠️ Needs Grafana                       | ⚠️ Needs Prometheus + Grafana         | ✅ Basic Web UI                     | ✅ Blackbox, Pingmesh integrate easily       |
| Alerting / Notifications       | ✅ Alert center + integrations      | ✅ Via Alertmanager                     | ⚠️ Custom needed                       | ✅ Email/Scripts                    | ✅ Blackbox + Prometheus alerting            |
| Kubernetes/Docker-Friendly     | ✅ Agent-based SaaS                 | ✅ Lightweight, container-native        | ✅ Can be containerized                | ⚠️ Legacy, harder to containerize  | ✅ Blackbox, Pingmesh (Docker-ready)         |
| Ease of Deployment             | ✅ SaaS click-based                 | ✅ Very easy with Prometheus            | ⚠️ Moderate effort                     | ⚠️ Moderate to high effort         | ✅ Blackbox easiest, Pingmesh acceptable     |
| Grafana Integration            | ⚠️ Limited                         | ✅ Native Prometheus metrics            | ✅ Prometheus metrics                   | ⚠️ None (custom scripts required)  | ✅ Blackbox, Pingmesh integrate smoothly     |
| License & Cost                 | ❌ Paid, Closed                     | ✅ Open Source                          | ✅ Open Source                          | ✅ Open Source                      | ✅ All open-source fit stack                 |
| Tool Maturity / Community      | ✅ Very mature, commercial backed  | ✅ Strong Prometheus community          | ⚠️ Microsoft internal origins          | ⚠️ Stable but old                  | ✅ Blackbox preferred for support/maturity   |
| Fit for Open-Source Stack      | ❌ SaaS; can’t integrate well       | ✅ Seamless match                       | ✅ Good fit for latency mesh            | ⚠️ Use-case specific fit          | ✅ Blackbox (excellent), Pingmesh (good)     |

---

## 🚨 Key Gaps in Blackbox Exporter vs. ThousandEyes

| Feature                       | Description                                                   | What We Lose Without It                                               |
| ----------------------------- | ------------------------------------------------------------- | --------------------------------------------------------------------- |
| **Traceroute / Path Tracing** | Identifies exact network hops and where delays occur          | Cannot isolate where network issues happen (e.g., in transit or edge) |
| **Jitter / Latency Graphing** | Measures variation in delay between packets                   | Cannot detect degraded user experience for real-time apps             |
| **Packet Loss Detection**     | Detects missing packets due to congestion, firewall, hardware | Hard to troubleshoot silent failures or partial outages               |

---

## 🧠 Importance of These Missing Features

### 🔄 Traceroute

* Critical for troubleshooting multi-hop WAN or cloud environments
* Enables root cause identification during performance degradation

### 📈 Jitter

* Essential for VoIP, Zoom, and real-time communication
* Impacts user experience even if uptime is technically 100%

### ❌ Packet Loss

* Invisible in normal HTTP/ICMP probes unless explicitly tested
* Leads to retransmission, buffering, or dropped calls

---

## 🧪 Why Blackbox Exporter is Still the Best Fit

| Criteria                    | Score (1–5) | Notes                                                    |
| --------------------------- | ----------- | -------------------------------------------------------- |
| **Prometheus Integration**  | 5           | Native support                                           |
| **Ease of Deployment**      | 5           | Lightweight container or binary                          |
| **Grafana Dashboarding**    | 5           | Prebuilt templates available                             |
| **Open Source License**     | 5           | MIT license — fits open model                            |
| **Extensibility**           | 4           | Custom modules/scripts can be added                      |
| **Out-of-the-box Coverage** | 3           | Covers HTTP, TCP, Ping, but lacks advanced net diagnosis |

---

## ✅ Plan to Extend Blackbox Exporter

We can overcome limitations via:

* 📦 Integrating **Smokeping** (lightweight) for jitter/packet loss
* 🔧 Custom **traceroute script** running in cronjob + Promtail → Loki → Grafana logs
* 🛠️ Using **mtr** or **Paris Traceroute** for CLI path visualization
* ⏱️ Scheduling probes from **multiple locations/agents** for better topology awareness

---

## 🧭 Conclusion

Blackbox Exporter is the most **cost-effective**, **integratable**, and **community-supported** option for basic to intermediate-level network monitoring within our open-source observability stack.

While it lacks advanced network path analytics, we can fill those gaps with:

* Smokeping (for jitter/loss)
* Custom scripts (for path trace)
* Enhanced Grafana dashboards

It fits our stack better than any other open-source or commercial solution for now, and provides full compatibility with our current architecture.

---

Let me know if you'd like to include installation instructions or Grafana dashboard templates next!
