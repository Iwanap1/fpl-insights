import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {

  static targets = [ "perfCharts", "teamCharts"]

  connect() {
  }

  toggleTeam() {
    console.log (this.teamChartsTarget)
    // this.teamChartsTarget.className("tab-pane fade active show")
    // this.perfChartsTarget.className("tab-pane fade")
    if (this.teamChartsTarget.classList.contains("active")) {
      // this.teamChartsTarget.classList.toggle("active")
      // this.teamChartsTarget.classList.toggle("show")
      this.perfChartsTarget.classList.toggle("active")
      this.perfChartsTarget.classList.toggle("show")
    }
  }

  togglePerformance() {
    console.log(this.perfChartsTarget)
    if (this.perfChartsTarget.classList.contains("active")) {
      this.perfChartsTarget.classList.toggle("active")
      this.perfChartsTarget.classList.toggle("show")
      this.teamChartsTarget.classList.toggle("active")
      this.teamChartsTarget.classList.toggle("show")
    }
  }

}
