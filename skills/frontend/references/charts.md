# Chart patterns (Chart.js)

Read this before building or changing a chart in a browser UI. The patterns use Chart.js 4.x; the
principles (one colour map, honest gaps, explicit empty state, forecasts never mistaken for actuals) hold
for any library.

## Contents
1. Colour map
2. Sizing and setup
3. Empty state
4. Time range control
5. Previous-period overlay
6. Forecast series and ghost markers

## 1. Colour map

Define series colours once. Mirror the same hex values in any backend that renders badges, emails or
exports, so a series is the same colour everywhere. The hex values below are placeholders: use your own
palette.

```javascript
// Single source of truth for series colours in charts, badges and pills
const COLOUR_MAP = {
  "Organic search": "#2F6FDB",  // placeholder
  "Paid":           "#E07B39",  // placeholder
};
```

```python
# Backend mirror: identical hex values
COLOUR_MAP = {"Organic search": "#2F6FDB", "Paid": "#E07B39"}
```

Never write a category colour inline. Look it up. A test that compares the two maps stops them drifting.

## 2. Sizing and setup

Load a pinned version from a CDN, or the project's bundler. Never an unpinned `latest`.

- Wrap the canvas in a `div` with an explicit height and `position: relative`.
- Set `responsive: true, maintainAspectRatio: false`.
- Set the height on the wrapper only, never on the `canvas`. A height on the canvas fights the resize
  observer and the chart grows on every resize.
- Time-series x axis: `autoSkip: false, maxRotation: 45` when every period label must show.
- Disable the built-in legend (`plugins: { legend: { display: false } }`) and build an HTML legend. It is
  styleable, wraps properly, can carry values ("Organic search 32%") and is readable by assistive technology.

```html
<div class="chart-legend">
  <span><span class="legend-swatch" style="background:#2F6FDB"></span>Organic search 32%</span>
  <span><span class="legend-swatch" style="background:#E07B39"></span>Paid 18%</span>
</div>
```

## 3. Empty state

Every chart handles "no data for this period". Never a blank canvas. Never fabricated values.

```javascript
// Chart.js has no built-in empty state. Register this plugin once at start-up.
const emptyStatePlugin = {
  id: "emptyState",
  afterDraw(chart) {
    if (!chart.chartArea) return; // not laid out yet on the first tick
    const hasData = chart.data.datasets.some(
      d => d.data && d.data.some(v => v !== null && v !== undefined)
    );
    if (hasData) return;
    const { ctx, chartArea: { left, top, width, height } } = chart;
    ctx.save();
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillStyle = "#9CA3AF";
    ctx.font = "14px sans-serif";
    ctx.fillText(
      chart.options.plugins?.emptyState?.message ?? "No data for this period",
      left + width / 2, top + height / 2
    );
    ctx.restore();
  }
};
Chart.register(emptyStatePlugin);

// data is a Chart.js data object: { labels, datasets }. Omit it to show the empty state.
function renderOrEmpty(canvasId, chartConfig, data) {
  const hasData = data && Array.isArray(data.datasets) && data.datasets.length > 0;
  return new Chart(document.getElementById(canvasId), {
    ...chartConfig,
    data: hasData ? data : { labels: [], datasets: [] },
    options: {
      ...chartConfig.options,
      plugins: { ...chartConfig.options?.plugins, emptyState: { message: "No data for this period" } }
    }
  });
}
```

Visual treatment by type: donut shows a grey ring and a centred label; bar shows empty axes and a centred
label; line shows the x axis only and a label.

## 4. Time range control

```javascript
// Scoped to its container: no global ids, so several controls can share a page.
function initTimeRangeControl(container, onChange, defaultRange = "30d") {
  const presets = ["7d", "30d", "90d", "all"];
  let active = defaultRange;
  let compare = false;

  function render() {
    container.innerHTML = presets.map(p =>
      `<button type="button" class="range-btn${p === active ? " active" : ""}"
         aria-pressed="${p === active}" data-range="${p}">${p.toUpperCase()}</button>`
    ).join("") +
    `<label><input type="checkbox" class="compare-toggle"${compare ? " checked" : ""}> vs previous period</label>`;

    container.querySelectorAll(".range-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        active = btn.dataset.range;
        render();
        onChange({ range: active, compare });
      });
    });
    container.querySelector(".compare-toggle").addEventListener("change", e => {
      compare = e.target.checked;
      onChange({ range: active, compare });
    });
  }
  render();
}
```

Re-rendering with `innerHTML` drops keyboard focus. Restore focus to the pressed button after `render()`,
or toggle classes instead of rebuilding. Put the active range in the URL so refresh and share keep it.

In a simplified view expose one default preset and one alternative. No custom date picker.

## 5. Previous-period overlay

```javascript
function addPreviousPeriodDataset(chart, previousData) {
  chart.data.datasets.push({
    label: "Previous period (actual)",
    data: previousData,       // null for missing days
    borderColor: "#9A9A9A",  // placeholder: a muted grey
    backgroundColor: "transparent",
    borderDash: [6, 3],
    borderWidth: 1.5,
    pointRadius: 3,
    spanGaps: false,          // a missing day is a break, never interpolated
  });
  chart.update();
}
```

- Current period: solid, full opacity, labelled "This period (actual)".
- Previous period: dashed, muted, labelled "Previous period (actual)".
- Both series named in the HTML legend.

## 6. Forecast series and ghost markers

Forecasts stay visibly distinct from actuals at all times. Two layers, each with its own dash pattern:

```javascript
const trendDataset = {
  label: "Trend projection",
  data: trendPoints,          // null for past periods, values for future only
  borderColor: "#9A9A9A",     // placeholder
  borderDash: [4, 4],
  borderWidth: 1,
  pointRadius: 3,
  spanGaps: false,
};

const modelForecastDataset = {
  label: "Forecast (estimate)",
  data: modelPoints,
  borderColor: "#7A5CC2",     // placeholder
  borderDash: [8, 4],
  borderWidth: 2,
  pointRadius: 4,
  spanGaps: false,
};
```

When actual data arrives for a period that was forecast, keep a ghost marker so the reader can see how
good the forecast was:

```javascript
// Points carry both values so the tooltip can show them.
const ghostPoints = actualPeriods.map(m => ({
  x: m.label, y: m.actual, forecast: m.forecast, actual: m.actual,
}));

const ghostDataset = {
  label: "_ghost",            // filter labels starting "_" out of the HTML legend
  data: ghostPoints,
  pointBackgroundColor: "#C8C8C8",  // placeholder
  pointRadius: 4,
  borderWidth: 0,
  showLine: false,
  tooltip: {
    callbacks: { label: ctx => `Forecast was ${ctx.raw.forecast}, actual was ${ctx.raw.actual}` }
  }
};
```

Keep a short note visible next to any forecast chart:

```html
<p class="forecast-note">Forecasts are estimates.</p>
```

Check the series ends where you think it does. A date helper that silently shifts a fixture by one period
puts a solid "actual" point in the future, and the totals still look plausible. Render the chart and look
at the last point against today's date.
