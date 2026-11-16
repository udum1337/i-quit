/* ============================================================
   Bootstrap, events, live tick
   ============================================================ */

function handleAction(action, el) {
  if (action === "tab") return switchTab(el.dataset.tab);
  if (action === "set-lang" || action === "settings-lang") return setLang(el.dataset.lang);
  if (action === "set-theme" || action === "settings-theme") return setTheme(el.dataset.theme);
  if (action === "open-onboarding" || action === "empty-onboarding") return openOnboarding("new");
  if (action === "edit-plan") return openOnboarding("edit");
  if (action === "reset-demo") return resetDemo();
  if (action === "ob-next") return onboardingNext();
  if (action === "ob-back") return onboardingBack();
  if (action === "ob-skip") return closeOnboarding();
  if (action === "ob-product") return onboardingSetProduct(el.dataset.id);
  if (action === "ob-currency") return onboardingSetCurrency(el.dataset.currency);
  if (action === "ob-quick") return onboardingQuick(Number(el.dataset.days));
  if (action === "ob-toggle-notifications") {
    onboarding.notifications = !onboarding.notifications;
    return renderOnboarding();
  }
  if (action === "open-slip") return openSheet("slip");
  if (action === "confirm-slip") return commitSlip();
  if (action === "close-sheet") return closeSheet();
  if (action === "undo-slip") return undoSlip();
  if (action === "open-currency") return openSheet("currency");
  if (action === "set-currency") return setCurrency(el.dataset.currency);
  if (action === "milestone") return openSheet("milestone", el.dataset.id);
  if (action === "achievement") return openSheet("achievement", el.dataset.id);
  if (action === "sources") return openSheet("sources");
  if (action === "disclaimer") return openSheet("disclaimer");
  if (action === "open-reset") return openSheet("reset");
  if (action === "confirm-reset") return resetAll();
  if (action === "export") return exportData();
  if (action === "toggle-notifications") return toggleNotifications();
  if (action === "toast-action") {
    if (ui.toast && typeof ui.toast.action === "function") {
      const fn = ui.toast.action;
      ui.toast = null;
      renderToast();
      fn();
    }
  }
}

function onClick(event) {
  const el = event.target.closest("[data-action]");
  if (!el) return;
  handleAction(el.dataset.action, el);
}

function onInput(event) {
  const field = event.target.closest("[data-ob-field]");
  if (!field) return;
  updateOnboardingField(field.dataset.obField, field.value);
}

function onKeydown(event) {
  if (event.key === "Escape" && ui.sheet) closeSheet();
}

function tick() {
  const newAchievements = syncUnlocked(true);
  const m = getMilestoneState();
  const count = m.unlocked.length;
  let needsRender = false;

  if (count > ui.lastMilestoneCount && m.prev) {
    showToast(t("newMilestone") + ": " + m.prev.title[state.lang]);
    needsRender = true;
  }
  ui.lastMilestoneCount = count;
  if (newAchievements.length) needsRender = true;

  if (needsRender) renderAll();
  else updateLive();
}

function initApp() {
  loadPrefs();
  applyTheme();

  syncUnlocked(false);
  ui.lastMilestoneCount = getMilestoneState().unlocked.length;
  ui.lastAchievementCount = state.unlocked.length;

  renderAll();
  fitPhone();

  document.addEventListener("click", onClick);
  document.addEventListener("input", onInput);
  document.addEventListener("change", onInput);
  document.addEventListener("keydown", onKeydown);
  window.addEventListener("resize", fitPhone);
  window.addEventListener("load", fitPhone);

  if (window.matchMedia) {
    const mq = window.matchMedia("(prefers-color-scheme: dark)");
    if (mq.addEventListener) {
      mq.addEventListener("change", function () {
        if (state.theme === "system") applyTheme();
      });
    }
  }

  setInterval(tick, 1000);
  setTimeout(fitPhone, 120);
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initApp);
} else {
  initApp();
}
