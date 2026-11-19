# Print and PDF output

Read this before building a printable view or a "Save as PDF" report from a browser page.

## Charts at print time

A `canvas` prints unreliably: it may be blank, mid-animation or sized for the screen layout. Render the
print charts into a hidden staging area and swap each canvas for an image just before printing.

```javascript
// Keep print chart instances by id, so capture does not depend on DOM traversal or globals.
const printChartInstances = new Map(); // chartId -> Chart instance

function registerPrintChart(chartId, chartInstance) {
  printChartInstances.set(chartId, chartInstance);
}

function capturePrintCharts() {
  const staging = document.getElementById("print-canvas-staging");
  staging.style.display = "block";
  staging.querySelectorAll("canvas[data-print-chart]").forEach(canvas => {
    const chart = printChartInstances.get(canvas.dataset.printChart);
    if (!chart) return;
    chart.update("none");               // synchronous paint, no animation
    const img = document.createElement("img");
    img.src = canvas.toDataURL("image/png");
    img.alt = canvas.getAttribute("aria-label") ?? "";
    canvas.replaceWith(img);
  });
}

window.addEventListener("beforeprint", capturePrintCharts);
window.addEventListener("afterprint", () => {
  document.getElementById("print-canvas-staging").style.display = "none";
});
```

Safari does not reliably run a `requestAnimationFrame` callback before the print dialog opens. That is why
the capture paints synchronously with `update("none")` instead of waiting a frame.

Because the canvas is replaced, a second print from the same page needs the charts rebuilt. Rebuild the
staging area in `afterprint`, or recreate it at the start of each capture.

## Print stylesheet

```css
@media print {
  nav, .toggle-bar, .filters, .edit-controls, .interactive, [data-no-print] {
    display: none !important;
  }
  body { background: white; color: black; }

  .print-section { break-inside: avoid; }
  .print-section h2 { break-after: avoid; }

  /* Colour is unreliable on paper and in greyscale PDFs: state it in words */
  .status-ok::after      { content: " (OK)"; }
  .status-warning::after { content: " (Warning)"; }
  .status-failing::after { content: " (Failing)"; }
}
```

`break-inside` and `break-after` are the current properties. Older engines need the `page-break-*` forms as
well; add them only if the project supports such browsers.

## Verify

Print to PDF from Chrome and Safari at least, open the PDF and look at every page: charts present and
complete, no control chrome, no section split across a page break, every status readable without colour.
