import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct Index {
  @State mdText: string = '# Hello Markdown\n\nType here...';
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Row() {
        TextInput({ text: this.mdText, placeholder: 'Enter Markdown...' })
          .layoutWeight(1)
          .height('100%')
          .onChange((value: string) => {
            this.mdText = value;
            this.controller.postMessage({ type: 'md', content: value });
          })

        Web({ src: $rawfile('index.html'), controller: this.controller })
          .layoutWeight(1)
          .height('100%')
          .javaScriptAccess(true)
          .onPageEnd(() => {
            this.controller.postMessage({ type: 'md', content: this.mdText });
          })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
