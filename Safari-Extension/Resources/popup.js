//safari.self.addEventListener("message", handleMessage);

function handleMessage(event) {
    var match = document.querySelector("input[type=tel]");
    if (match == null) {
        match = document.querySelector("input[type=number]");
    }
    if (match == null) {
        var possibleMatches = document.getElementsByTagName("input");
        for (let possibleMatch of possibleMatches) {
            if (possibleMatch.type == "text") {
                match = possibleMatch;
                break;
            }
        }
    }
    
    if (match != null) {
        match.value = event.message.otp;
        match.dispatchEvent(new Event('input', { bubbles: true }));
    }
}
customElements.define("svg-progress-circle", class extends HTMLElement {
  connectedCallback() {
    let d = 'M5,30a12.5,12.5,0,1,1,15,0a12.5,12.5,0,1,1,-15,0'; // circle
    this.innerHTML =
    `<svg viewBox="0 0 32 32">
     <path stroke-dasharray="1" stroke-dashoffset="-25"
           pathlength="100" d="${d}" fill="none" stroke="green" stroke-width="1"/>
     <path stroke-dasharray="1" stroke-dashoffset="-25"
           pathlength="100" d="${d}" fill="none"
           stroke="${this.getAttribute("color")||"red"}" stroke-width="1"/>
     <text x="50%" y="50%" text-anchor="middle">30%</text></svg>`;
     
    this.style.display='inline-block';
    this.percent = this.getAttribute("percent");
  }
  set percent(val = 0) {
    this.setAttribute("percent", val);
    let dash = val + " " + (100 - val);
    this.querySelector("path+path").setAttribute('stroke-dasharray', dash);
    this.querySelector("text").innerHTML = val + "%";
    this.querySelector("input").value = val;
  }
})
