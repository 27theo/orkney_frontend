import TimeAgo from 'javascript-time-ago'
import en from 'javascript-time-ago/locale/en'

TimeAgo.addDefaultLocale(en);
const timeAgo = new TimeAgo('en-GB');

window.customElements.define('time-ago',
    class extends HTMLElement {
        constructor() { super(); }
        connectedCallback() { this.setTextContent(); }
        attributeChangedCallback() { this.setTextContent(); }

        setTextContent() {
            const epoch = Number(this.getAttribute('epoch'));
            const ago = timeAgo.format(epoch * 1000);
            this.textContent = ago;
        }
    }
);
