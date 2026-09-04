import { BlockType, MarkdownBlock, parseMarkdown } from '../../common/utils/MarkdownParser';

@Component
export struct PreviewArea {
  @Prop md: string;
  @Prop bg: string;
  @Prop txt: string;

  build() {
    Column({ space: 10 }) {
      Row() {
        Text('\u9884\u89c8').fontSize(11).fontColor('#7B8190');
        Blank();
        Text('\u53ea\u8bfb\u89c6\u56fe').fontSize(10).fontColor('#9AA1AE');
      }
      Scroll() {
        Text(this.renderedText())
          .fontSize(14)
          .lineHeight(22)
          .fontColor(this.txt)
          .width('100%')
          .textAlign(TextAlign.Start);
      }.layoutWeight(1).width('100%');
    }
      .width('100%')
      .height('100%')
      .padding(16)
      .backgroundColor(this.bg)
      .borderRadius(20);
  }

  private renderedText(): string {
    const blocks = parseMarkdown(this.md);
    if (blocks.length === 0) {
      return '\u5f00\u59cb\u8f93\u5165\u540e\uff0c\u8fd9\u91cc\u4f1a\u663e\u793a\u9884\u89c8\u5185\u5bb9\u3002';
    }

    const lines: string[] = [];
    for (let i = 0; i < blocks.length; i++) {
      lines.push(this.renderBlock(blocks[i], i));
    }
    return lines.join('\n\n');
  }

  private renderBlock(block: MarkdownBlock, index: number): string {
    const content = block.spans.map((span) => span.text).join('');
    if (block.type === BlockType.CODE_BLOCK) {
      return `\u4ee3\u7801\u5757\n${content}`;
    }
    if (block.type === BlockType.UNORDERED_LIST) {
      return `- ${content}`;
    }
    if (block.type === BlockType.ORDERED_LIST) {
      return `${index + 1}. ${content}`;
    }
    if (block.type === BlockType.TASK_LIST) {
      return `${block.checked ? '[x]' : '[ ]'} ${content}`;
    }
    if (block.type === BlockType.BLOCKQUOTE) {
      return `> ${content}`;
    }
    if (block.type === BlockType.HORIZONTAL_RULE) {
      return '--------';
    }
    return content;
  }
}

@Component
export struct WordCountBar {
  @Prop count: number;
  @Prop lines: number;
  @Prop bg: string;
  @Prop sub: string;

  build() {
    Row() {
      Text(`\u5b57\u6570 ${this.count}`).fontSize(11).fontColor(this.sub);
      Text(`\u884c\u6570 ${this.lines}`).fontSize(11).fontColor(this.sub).margin({ left: 14 });
    }
      .height(30)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.End)
      .backgroundColor(this.bg);
  }
}
