async function loadHealthz() {
  const pre = document.getElementById("health-output");
  try {
    const res = await fetch("/healthz", { cache: "no-store" });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();

    document.getElementById("build-number").textContent = `#${data.build_number || "1"}`;
    document.getElementById("commit-sha").textContent = data.commit_sha || "local-dev";
    document.getElementById("commit-msg").textContent = data.commit_message || "-";
    document.getElementById("app-status").textContent = data.status === "UP" ? "Online" : data.status;
    document.getElementById("app-timestamp").textContent = data.timestamp ? new Date(data.timestamp).toLocaleString() : "-";

    if (pre) {
      pre.textContent = JSON.stringify(data, null, 2);
      pre.classList.add("visible");
    }
  } catch (err) {
    if (pre) {
      pre.textContent = "Error memanggil /healthz: " + err.message;
      pre.classList.add("visible");
    }
  }
}

document.addEventListener("DOMContentLoaded", () => {
  loadHealthz();
  document.getElementById("refresh-btn")?.addEventListener("click", loadHealthz);
});