/* ============================================================
   Timeline screen
   ============================================================ */

function timelineGroupLabel(group) {
  if (group === "hours") return t("groupHours");
  if (group === "days") return t("groupDays");
  if (group === "months") return t("groupMonths");
  return t("groupYears");
}

function timelineItem(m, unlocked) {
  return '<button type="button" class="tl-item ' + (unlocked ? "is-unlocked" : "is-locked") + '" data-action="milestone" data-id="' + m.id + '">' +
    '<span class="tl-rail"><span class="tl-dot">' + (unlocked ? icon("check", 11) : "") + "</span></span>" +
    '<span class="tl-body">' +
      '<span class="tl-time">' + m.time[state.lang] + "</span>" +
      '<span class="tl-title">' + m.title[state.lang] + "</span>" +
      '<span class="tl-desc">' + m.desc[state.lang] + "</span>" +
    "</span>" +
    "</button>";
}

function renderTimeline() {
  const el = document.getElementById("screen-timeline");
  if (!el) return;

  const m = getMilestoneState();
  const elapsed = m.elapsed;
  const next = m.next;
  const groups = ["hours", "days", "months", "years"];
  let markerInserted = false;

  const body = groups.map(function (group) {
    const items = MILESTONES.filter(function (ms) { return ms.group === group; });
    if (!items.length) return "";
    let html = '<div class="tl-group"><div class="tl-group-title">' + timelineGroupLabel(group) + "</div>";
    items.forEach(function (ms) {
      const unlocked = elapsed >= ms.at;
      if (!unlocked && !markerInserted) {
        html += '<div class="tl-now">' +
          '<span class="tl-rail"><span class="tl-pulse"></span></span>' +
          '<span class="tl-now-body">' + icon("target", 12) + " <span data-live=\"timeline-now\">" + t("youAreHere") + " · " + fmtDays(getCurrentDays()) + "</span></span>" +
          "</div>";
        markerInserted = true;
      }
      html += timelineItem(ms, unlocked);
    });
    html += "</div>";
    return html;
  }).join("");

  const tail = !markerInserted
    ? '<div class="tl-now">' +
        '<span class="tl-rail"><span class="tl-pulse"></span></span>' +
        '<span class="tl-now-body">' + icon("target", 12) + " <span data-live=\"timeline-now\">" + t("youAreHere") + " · " + fmtDays(getCurrentDays()) + "</span></span>" +
      "</div>"
    : "";

  const overall = MILESTONES.length ? (m.unlocked.length / MILESTONES.length) * 100 : 0;
  const summarySub = next
    ? t("unlockIn") + " " + fmtDurationShort(next.at - elapsed) + " · " + next.time[state.lang]
    : t("allDone");

  el.innerHTML =
    '<div class="screen-head">' +
      '<div class="eyebrow">' + t("progressLabel") + "</div>" +
      "<h1>" + t("timelineTitle") + "</h1>" +
      "<p>" + t("timelineSub") + "</p>" +
    "</div>" +

    '<div class="tl-summary">' +
      '<div class="tl-summary-top">' +
        '<div class="tl-summary-title">' + t("timelineSummary") + "</div>" +
        '<div class="tl-summary-count" data-live="milestone-count">' + m.unlocked.length + " " + t("of") + " " + MILESTONES.length + "</div>" +
      "</div>" +
      '<div class="progress-track"><div class="progress-fill" style="width:' + overall.toFixed(2) + '%"></div></div>' +
      '<div class="tl-summary-sub">' + summarySub + "</div>" +
    "</div>" +

    (state.product !== "cigarettes" ? '<div class="tl-note">' + icon("info", 14) + "<span>" + t("timelineProductNote") + "</span></div>" : "") +

    body + tail +

    '<div style="display:flex;justify-content:center;margin-top:18px">' +
      '<button type="button" class="source-chip" data-action="sources">' + icon("shield", 12) + " " + t("sourcesLabel") + "</button>" +
    "</div>" +
    '<div class="settings-footer" style="padding-top:14px">' + t("settingsFooter") + "</div>";
}
