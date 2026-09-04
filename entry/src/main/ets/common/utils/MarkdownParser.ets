export enum TextStyle {
  NORMAL = 0,
  BOLD = 1,
  ITALIC = 2,
  CODE = 3,
  LINK = 4,
  STRIKE = 5
}

export enum BlockType {
  PARAGRAPH = 0,
  HEADING1 = 1,
  HEADING2 = 2,
  HEADING3 = 3,
  HEADING4 = 4,
  CODE_BLOCK = 5,
  BLOCKQUOTE = 6,
  UNORDERED_LIST = 7,
  ORDERED_LIST = 8,
  TASK_LIST = 9,
  HORIZONTAL_RULE = 10,
  TABLE = 11
}

export class TextSpan {
  text: string = '';
  style: TextStyle = TextStyle.NORMAL;
  link?: string;

  constructor(text: string, style: TextStyle = TextStyle.NORMAL, link?: string) {
    this.text = text;
    this.style = style;
    this.link = link;
  }
}

export class MarkdownBlock {
  type: BlockType = BlockType.PARAGRAPH;
  spans: TextSpan[] = [];
  language?: string;
  checked?: boolean;

  constructor(type: BlockType, spans: TextSpan[] = []) {
    this.type = type;
    this.spans = spans;
  }
}

export function parseMarkdown(markdown: string): MarkdownBlock[] {
  const lines = markdown.split('\n');
  const blocks: MarkdownBlock[] = [];
  let i = 0;

  while (i < lines.length) {
    const trimmed = lines[i].trim();
    if (!trimmed) {
      i++;
      continue;
    }

    if (trimmed.startsWith('#### ')) {
      blocks.push(parseHeading(trimmed, 4));
      i++;
      continue;
    }
    if (trimmed.startsWith('### ')) {
      blocks.push(parseHeading(trimmed, 3));
      i++;
      continue;
    }
    if (trimmed.startsWith('## ')) {
      blocks.push(parseHeading(trimmed, 2));
      i++;
      continue;
    }
    if (trimmed.startsWith('# ')) {
      blocks.push(parseHeading(trimmed, 1));
      i++;
      continue;
    }

    if (trimmed.startsWith('```')) {
      const lang = trimmed.slice(3).trim();
      const codeLines: string[] = [];
      i++;
      while (i < lines.length && !lines[i].trim().startsWith('```')) {
        codeLines.push(lines[i]);
        i++;
      }
      const block = new MarkdownBlock(BlockType.CODE_BLOCK, [new TextSpan(codeLines.join('\n'))]);
      block.language = lang.length > 0 ? lang : undefined;
      blocks.push(block);
      if (i < lines.length) {
        i++;
      }
      continue;
    }

    if (trimmed.startsWith('> ')) {
      blocks.push(new MarkdownBlock(BlockType.BLOCKQUOTE, parseInline(trimmed.slice(2))));
      i++;
      continue;
    }

    if (trimmed.startsWith('- [x] ') || trimmed.startsWith('- [X] ')) {
      const block = new MarkdownBlock(BlockType.TASK_LIST, parseInline(trimmed.slice(6)));
      block.checked = true;
      blocks.push(block);
      i++;
      continue;
    }
    if (trimmed.startsWith('- [ ] ')) {
      const block = new MarkdownBlock(BlockType.TASK_LIST, parseInline(trimmed.slice(6)));
      block.checked = false;
      blocks.push(block);
      i++;
      continue;
    }

    if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      blocks.push(new MarkdownBlock(BlockType.UNORDERED_LIST, parseInline(trimmed.slice(2))));
      i++;
      continue;
    }

    const orderedListMatch = trimmed.match(/^(\d+)\.\s+/);
    if (orderedListMatch) {
      const content = trimmed.slice(orderedListMatch[0].length);
      blocks.push(new MarkdownBlock(BlockType.ORDERED_LIST, parseInline(content)));
      i++;
      continue;
    }

    if (trimmed === '---' || trimmed === '***' || trimmed === '___') {
      blocks.push(new MarkdownBlock(BlockType.HORIZONTAL_RULE, []));
      i++;
      continue;
    }

    blocks.push(new MarkdownBlock(BlockType.PARAGRAPH, parseInline(trimmed)));
    i++;
  }

  return blocks;
}

function parseHeading(line: string, level: number): MarkdownBlock {
  const content = line.replace(/^#+\s/, '');
  let blockType = BlockType.HEADING4;
  if (level === 1) {
    blockType = BlockType.HEADING1;
  } else if (level === 2) {
    blockType = BlockType.HEADING2;
  } else if (level === 3) {
    blockType = BlockType.HEADING3;
  }
  return new MarkdownBlock(blockType, parseInline(content));
}

function parseInline(text: string): TextSpan[] {
  const spans: TextSpan[] = [];
  let remaining = text;

  while (remaining.length > 0) {
    const codeMatch = remaining.match(/^`([^`]+)`/);
    if (codeMatch) {
      spans.push(new TextSpan(codeMatch[1], TextStyle.CODE));
      remaining = remaining.slice(codeMatch[0].length);
      continue;
    }

    const boldMatch = remaining.match(/^\*\*([^*]+)\*\*/);
    const underlineBoldMatch = remaining.match(/^__([^_]+)__/);
    const bold = boldMatch || underlineBoldMatch;
    if (bold) {
      spans.push(new TextSpan(bold[1], TextStyle.BOLD));
      remaining = remaining.slice(bold[0].length);
      continue;
    }

    const italicMatch = remaining.match(/^\*([^*]+)\*/);
    const underlineItalicMatch = remaining.match(/^_([^_]+)_/);
    const italic = italicMatch || underlineItalicMatch;
    if (italic) {
      spans.push(new TextSpan(italic[1], TextStyle.ITALIC));
      remaining = remaining.slice(italic[0].length);
      continue;
    }

    const strikeMatch = remaining.match(/^~~([^~]+)~~/);
    if (strikeMatch) {
      spans.push(new TextSpan(strikeMatch[1], TextStyle.STRIKE));
      remaining = remaining.slice(strikeMatch[0].length);
      continue;
    }

    const linkMatch = remaining.match(/^\[([^\]]+)\]\(([^)]+)\)/);
    if (linkMatch) {
      spans.push(new TextSpan(linkMatch[1], TextStyle.LINK, linkMatch[2]));
      remaining = remaining.slice(linkMatch[0].length);
      continue;
    }

    let nextSpecial = remaining.length;
    const specialPatterns = ['`', '**', '__', '*', '_', '~~', '['];
    for (const pattern of specialPatterns) {
      const idx = remaining.indexOf(pattern);
      if (idx > 0 && idx < nextSpecial) {
        nextSpecial = idx;
      }
    }

    const plainText = nextSpecial > 0 ? remaining.slice(0, nextSpecial) : remaining.charAt(0);
    spans.push(new TextSpan(plainText, TextStyle.NORMAL));
    remaining = remaining.slice(plainText.length);
  }

  return spans;
}

export function getWordCount(markdown: string): number {
  return markdown.replace(/\s/g, '').length;
}
