/* ============================================================
   UI core: chrome, tabs, live values, sheet plumbing
   ============================================================ */

function icon(name, size) {
  const s = size || 20;
  return '<svg viewBox="0 0 24 24" width="' + s + '" height="' + s + '" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">' + (ICONS[name] || ICONS.info) + '</svg>';
}

function renderChrome() {
  const logo = document.getElementById("logo");
  if (logo) logo.innerHTML = icon("logo", 24);
  setText("brand-name", t("appName"));
  setText("brand-badge", t("prototype"));
  setText("brand-sub", t("brandSub"));
  setText("btn-onboarding", t("btnOnboarding"));
  setText("btn-reset", t("btnResetDemo"));
  setText("footer-note", t("footerNote"));

  document.querySelectorAll('[data-action="set-lang"]').forEach(function (btn) {
    btn.classList.toggle("is-active", btn.dataset.lang === state.lang);
  });
  document.querySelectorAll('[data-action="set-theme"]').forEach(function (btn) {
    btn.classList.toggle("is-active", btn.dataset.theme === state.theme);
  });
}

function setText(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value;
}

function renderTabs() {
  const tabs = [
    { id: "home", icon: "home", label: t("navHome") },
    { id: "timeline", icon: "timeline", label: t("navTimeline") },
    { id: "progress", icon: "chart", label: t("navProgress") },
    { id: "settings", icon: "settings", label: t("navSettings") }
  ];
  const bar = document.getElementById("tabbar");
  if (!bar) return;
  bar.innerHTML = tabs.map(function (tab) {
    return '<button type="button" class="tab' + (ui.screen === tab.id ? " is-active" : "") + '" data-action="tab" data-tab="' + tab.id + '">' +
      icon(tab.icon, 24) +
      "<span>" + tab.label + "</span>" +
      "</button>";
  }).join("");
}

function renderToast() {
  const el = document.getElementById("toast");
  if (!el) return;
  if (!ui.toast) {
    el.classList.remove("is-visible");
    el.innerHTML = "";
    return;
  }
  el.innerHTML = "<span>" + ui.toast.message + "</span>" +
    (ui.toast.actionLabel ? '<button type="button" data-action="toast-action">' + ui.toast.actionLabel + "</button>" : "");
  el.classList.add("is-visible");
}

function openSheet(type, payload) {
  ui.sheet = { type: type, payload: payload || null };
  renderSheet();
  const sheet = document.getElementById("sheet");
  const backdrop = document.getElementById("sheet-backdrop");
  if (sheet) {
    sheet.classList.add("is-open");
    sheet.setAttribute("aria-hidden", "false");
  }
  if (backdrop) backdrop.classList.add("is-open");
}

function closeSheet() {
  ui.sheet = null;
  const sheet = document.getElementById("sheet");
  const backdrop = document.getElementById("sheet-backdrop");
  if (sheet) {
    sheet.classList.remove("is-open");
    sheet.setAttribute("aria-hidden", "true");
  }
  if (backdrop) backdrop.classList.remove("is-open");
  setTimeout(function () {
    if (!ui.sheet && sheet) sheet.innerHTML = "";
  }, 340);
}

function renderAll() {
  applyTheme();
  renderChrome();
  renderTabs();
  document.querySelectorAll(".screen").forEach(function (el) {
    el.classList.toggle("is-active", el.dataset.screen === ui.screen);
  });
  renderScreen(ui.screen);

  const phone = document.getElementById("phone");
  const ob = document.getElementById("onboarding");
  if (ob) {
    ob.classList.toggle("is-open", onboarding.open);
    ob.setAttribute("aria-hidden", onboarding.open ? "false" : "true");
    if (onboarding.open) renderOnboarding();
    else ob.innerHTML = "";
  }
  if (phone) phone.classList.toggle("onboarding-open", onboarding.open);

  if (ui.sheet) {
    renderSheet();
    const sheet = document.getElementById("sheet");
    const backdrop = document.getElementById("sheet-backdrop");
    if (sheet) sheet.classList.add("is-open");
    if (backdrop) backdrop.classList.add("is-open");
  }

  renderToast();
  updateLive();
  fitPhone();
}

function updateLive() {
  const m = getMilestoneState();
  const elapsed = m.elapsed;
  const next = m.next;
  const progress = m.progress;
  const currentDays = getCurrentDays();
  const totalDays = getTotalDays();
  const bestDays = getBestDays();
  const saved = getSavedTotal();
  const avoided = getAvoidedTotal();
  const unlockedAch = getUnlockedAchievements().length;

  const values = {
    days: String(currentDays),
    "days-label": pluralDays(currentDays),
    hms: fmtHMS(elapsed),
    "hero-next": next ? fmtCountdown(next.at - elapsed) : t("allMilestonesDone"),
    "next-countdown": next ? fmtCountdown(next.at - elapsed) : t("allDone"),
    "next-title": next ? next.title[state.lang] : t("allMilestonesDone"),
    "next-time": next ? next.time[state.lang] : "",
    saved: fmtMoney(saved),
    "saved-big": fmtMoney(saved),
    avoided: formatAvoided(),
    "total-days": String(totalDays),
    "total-days-label": pluralDays(totalDays),
    "best-days": String(bestDays),
    "best-days-label": pluralDays(bestDays),
    "best-short": fmtDays(bestDays),
    "total-short": fmtDays(totalDays),
    "streak-days": String(currentDays),
    "streak-days-label": pluralDays(currentDays),
    slips: String(state.slips),
    "profile-sub": formatProfileSub(),
    "chart-sub": t("forDays") + " " + fmtDays(totalDays),
    "timeline-now": t("youAreHere") + " · " + fmtDays(currentDays),
    "milestone-count": m.unlocked.length + " " + t("of") + " " + MILESTONES.length,
    "ach-count": unlockedAch + " " + t("of") + " " + ACHIEVEMENTS.length,
    today: fmtDate(Date.now(), "long"),
    "current-benefit-title": m.prev ? m.prev.title[state.lang] : t("startBenefitTitle"),
    "current-benefit-desc": m.prev ? m.prev.desc[state.lang] : t("startBenefitDesc")
  };

  document.querySelectorAll("[data-live]").forEach(function (el) {
    const key = el.dataset.live;
    if (key === "ring" || key === "next-progress") return;
    if (values[key] != null) el.textContent = values[key];
  });

  document.querySelectorAll('[data-live="ring"]').forEach(function (el) {
    const c = 2 * Math.PI * 84;
    el.setAttribute("stroke-dashoffset", String(c * (1 - progress)));
  });
  document.querySelectorAll('[data-live="next-progress"]').forEach(function (el) {
    el.style.width = (progress * 100).toFixed(2) + "%";
  });
}

function fitPhone() {
  const wrap = document.getElementById("phone-wrap");
  if (!wrap) return;
  if (document.documentElement.classList.contains("is-standalone")) {
    wrap.style.removeProperty("width");
    wrap.style.removeProperty("height");
    document.documentElement.style.removeProperty("--phone-scale");
    return;
  }
  const bar = document.querySelector(".stage-bar");
  const top = bar ? bar.getBoundingClientRect().bottom + 16 : 20;
  const availH = Math.max(320, window.innerHeight - top - 46);
  const availW = Math.max(240, window.innerWidth - 24);
  const scale = Math.min(1, availH / 852, availW / 393);
  document.documentElement.style.setProperty("--phone-scale", scale.toFixed(4));
  wrap.style.width = Math.round(393 * scale) + "px";
  wrap.style.height = Math.round(852 * scale) + "px";
}

function renderScreen(name) {
  if (name === "home") renderHome();
  else if (name === "timeline") renderTimeline();
  else if (name === "progress") renderProgress();
  else if (name === "settings") renderSettings();
}
