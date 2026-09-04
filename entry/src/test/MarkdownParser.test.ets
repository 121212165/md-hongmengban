
import { describe, it, expect, beforeAll, afterAll } from '@ohos.hypium';
import {
  TextStyle,
  BlockType,
  TextSpan,
  MarkdownBlock,
  parseMarkdown,
  getWordCount
} from '../main/ets/common/utils/MarkdownParser';

export default function markdownParserTest() {
  describe('MarkdownParser测试集', () => {
    // 测试TextStyle枚举
    describe('TextStyle枚举', () => {
      it('should_have_normal_style', 0, (): void => {
        expect(TextStyle.NORMAL).assertEqual(0);
      });

      it('should_have_bold_style', 0, (): void => {
        expect(TextStyle.BOLD).assertEqual(1);
      });

      it('should_have_italic_style', 0, (): void => {
        expect(TextStyle.ITALIC).assertEqual(2);
      });

      it('should_have_code_style', 0, (): void => {
        expect(TextStyle.CODE).assertEqual(3);
      });

      it('should_have_link_style', 0, (): void => {
        expect(TextStyle.LINK).assertEqual(4);
      });

      it('should_have_strike_style', 0, (): void => {
        expect(TextStyle.STRIKE).assertEqual(5);
      });
    });

    // 测试BlockType枚举
    describe('BlockType枚举', () => {
      it('should_have_paragraph_type', 0, (): void => {
        expect(BlockType.PARAGRAPH).assertEqual(0);
      });

      it('should_have_heading1_type', 0, (): void => {
        expect(BlockType.HEADING1).assertEqual(1);
      });

      it('should_have_heading2_type', 0, (): void => {
        expect(BlockType.HEADING2).assertEqual(2);
      });

      it('should_have_code_block_type', 0, (): void => {
        expect(BlockType.CODE_BLOCK).assertEqual(5);
      });

      it('should_have_blockquote_type', 0, (): void => {
        expect(BlockType.BLOCKQUOTE).assertEqual(6);
      });

      it('should_have_horizontal_rule_type', 0, (): void => {
        expect(BlockType.HORIZONTAL_RULE).assertEqual(10);
      });
    });

    // 测试MarkdownBlock类
    describe('MarkdownBlock类', () => {
      it('should_create_block_with_default_values', 0, (): void => {
        const block = new MarkdownBlock(BlockType.PARAGRAPH);
        expect(block.type).assertEqual(BlockType.PARAGRAPH);
        expect(block.spans).assertEqual([]);
      });

      it('should_create_block_with_spans', 0, (): void => {
        const spans = [new TextSpan('test')];
        const block = new MarkdownBlock(BlockType.PARAGRAPH, spans);
        expect(block.spans.length).assertEqual(1);
        expect(block.spans[0].text).assertEqual('test');
      });

      it('should_support_language_property', 0, (): void => {
        const block = new MarkdownBlock(BlockType.CODE_BLOCK, [new TextSpan('code')]);
        block.language = 'javascript';
        expect(block.language).assertEqual('javascript');
      });

      it('should_support_checked_property', 0, (): void => {
        const block = new MarkdownBlock(BlockType.TASK_LIST, [new TextSpan('task')]);
        block.checked = true;
        expect(block.checked).assertTrue();
      });
    });

    // 测试TextSpan类
    describe('TextSpan类', () => {
      it('should_create_span_with_text', 0, (): void => {
        const span = new TextSpan('hello');
        expect(span.text).assertEqual('hello');
        expect(span.style).assertEqual(TextStyle.NORMAL);
      });

      it('should_create_span_with_style', 0, (): void => {
        const span = new TextSpan('hello', TextStyle.BOLD);
        expect(span.style).assertEqual(TextStyle.BOLD);
      });

      it('should_create_span_with_link', 0, (): void => {
        const span = new TextSpan('link', TextStyle.LINK, 'https://example.com');
        expect(span.link).assertEqual('https://example.com');
      });
    });

    // 测���parseMarkdown函数 - 标题解析
    describe('parseMarkdown_标题解析', () => {
      it('should_parse_h1', 0, (): void => {
        const blocks = parseMarkdown('# Hello');
        expect(blocks.length).assertEqual(1);
        expect(blocks[0].type).assertEqual(BlockType.HEADING1);
      });

      it('should_parse_h2', 0, (): void => {
        const blocks = parseMarkdown('## Hello');
        expect(blocks[0].type).assertEqual(BlockType.HEADING2);
      });

      it('should_parse_h3', 0, (): void => {
        const blocks = parseMarkdown('### Hello');
        expect(blocks[0].type).assertEqual(BlockType.HEADING3);
      });

      it('should_parse_h4', 0, (): void => {
        const blocks = parseMarkdown('#### Hello');
        expect(blocks[0].type).assertEqual(BlockType.HEADING4);
      });
    });

    // 测试parseMarkdown函数 - 基础语法
    describe('parseMarkdown_基础语法', () => {
      it('should_parse_paragraph', 0, (): void => {
        const blocks = parseMarkdown('Hello World');
        expect(blocks[0].type).assertEqual(BlockType.PARAGRAPH);
      });

      it('should_parse_code_block', 0, (): void => {
        const blocks = parseMarkdown('```javascript\ncode\n```');
        expect(blocks[0].type).assertEqual(BlockType.CODE_BLOCK);
      });

      it('should_parse_blockquote', 0, (): void => {
        const blocks = parseMarkdown('> quote');
        expect(blocks[0].type).assertEqual(BlockType.BLOCKQUOTE);
      });

      it('should_parse_unordered_list', 0, (): void => {
        const blocks = parseMarkdown('- item');
        expect(blocks[0].type).assertEqual(BlockType.UNORDERED_LIST);
      });

      it('should_parse_ordered_list', 0, (): void => {
        const blocks = parseMarkdown('1. item');
        expect(blocks[0].type).assertEqual(BlockType.ORDERED_LIST);
      });

      it('should_parse_horizontal_rule', 0, (): void => {
        const blocks = parseMarkdown('---');
        expect(blocks[0].type).assertEqual(BlockType.HORIZONTAL_RULE);
      });

      it('should_parse_task_list_checked', 0, (): void => {
        const blocks = parseMarkdown('- [x] done');
        expect(blocks[0].type).assertEqual(BlockType.TASK_LIST);
        expect(blocks[0].checked).assertTrue();
      });

      it('should_parse_task_list_unchecked', 0, (): void => {
        const blocks = parseMarkdown('- [ ] pending');
        expect(blocks[0].type).assertEqual(BlockType.TASK_LIST);
        expect(blocks[0].checked).assertFalse();
      });
    });

    // 测试parseMarkdown函数 - 空输入和边界情况
    describe('parseMarkdown_边界情况', () => {
      it('should_handle_empty_string', 0, (): void => {
        const blocks = parseMarkdown('');
        expect(blocks.length).assertEqual(0);
      });

      it('should_handle_whitespace_only', 0, (): void => {
        const blocks = parseMarkdown('   \n   \n   ');
        expect(blocks.length).assertEqual(0);
      });

      it('should_handle_multiple_lines', 0, (): void => {
        const blocks = parseMarkdown('Line 1\nLine 2\nLine 3');
        expect(blocks.length).assertEqual(3);
      });
    });

    // 测试getWordCount函数
    describe('getWordCount', () => {
      it('should_count_empty_string', 0, (): void => {
        expect(getWordCount('')).assertEqual(0);
      });

      it('should_count_simple_text', 0, (): void => {
        expect(getWordCount('Hello')).assertEqual(5);
      });

      it('should_count_chinese_text', 0, (): void => {
        expect(getWordCount('你好')).assertEqual(2);
      });

      it('should_count_with_newlines', 0, (): void => {
        expect(getWordCount('Hello\nWorld')).assertEqual(11);
      });
    });
  });
}