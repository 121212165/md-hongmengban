import { ToolbarButton, TOOLBAR_BUTTONS } from '../../common/constants/CommonConstants';

@Component
export struct EditorArea {
  @Link content: string;
  @Prop placeholder: string;
  @Prop editorBgColor: string;
  @Prop textColor: string;
  onContentChange?: (value: string) => void;

  build() {
    Column() {
      TextArea({
        text: this.content,
        placeholder: this.placeholder
      })
        .backgroundColor(this.editorBgColor)
        .fontColor(this.textColor)
        .placeholderColor('#8F96A3')
        .fontSize(15)
        .caretColor('#0A84FF')
        .width('100%')
        .height('100%')
        .borderRadius(20)
        .padding(16)
        .onChange((value: string): void => {
          this.content = value;
          if (this.onContentChange) {
            this.onContentChange(value);
          }
        });
    }
  }
}

@Component
export struct ToolbarPanel {
  @Prop buttons: ToolbarButton[] = TOOLBAR_BUTTONS;
  onInsert?: (text: string) => void;

  build() {
    Row() {
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.buttons, (button: ToolbarButton) => {
            Column({ space: 2 }) {
              Text(button.icon).fontSize(13).fontColor('#111111');
              Text(button.label).fontSize(9).fontColor('#6B7280');
            }
              .width(52)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(14)
              .onClick((): void => {
                if (this.onInsert) {
                  this.onInsert(button.insertText);
                }
              });
          });
        }.padding({ left: 12, right: 12, top: 8, bottom: 8 });
      }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
    }.backgroundColor('#EEF2F6');
  }
}
