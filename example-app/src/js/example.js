import { Nfc } from '@trentrand/capacitor-nfc';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    Nfc.echo({ value: inputValue })
}
