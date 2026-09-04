import { describe, it, expect } from '@ohos/hypium';
import { createDocument, CURRENT_DOC_KEY, DOCUMENTS_KEY } from '../../../main/ets/models/DocumentModel';
import {
  BlockType,
  TextStyle,
  parseMarkdown,
  getWordCount
} from '../../../main/ets/common/utils/MarkdownParser';
import {
  DARK_THEME,
  LIGHT_THEME,
  SyncStatus,
  TOOLBAR_BUTTONS
} from '../../../main/ets/common/constants/CommonConstants';

export default function abilityTest() {
  describe('HongmengMdOhosTest', () => {
    describe('DocumentModel', () => {
      it('should_create_markdown_document_with_defaults', 0, () => {
        const before = Date.now();
        const doc = createDocument('notes');
        const after = Date.now();

        expect(doc.name).assertEqual('notes.md');
        expect(doc.content).assertEqual('');
        expect(doc.id).assertContain('doc_');
        expect(doc.createdAt >= before).assertTrue();
        expect(doc.updatedAt <= after).assertTrue();
        expect(doc.createdAt).assertEqual(doc.updatedAt);
      });

      it('should_preserve_extension_and_content', 0, () => {
        const doc = createDocument('draft.md', '# Title');

        expect(doc.name).assertEqual('draft.md');
        expect(doc.content).assertEqual('# Title');
      });

      it('should_expose_storage_keys', 0, () => {
        expect(DOCUMENTS_KEY).assertEqual('harmony_md_documents');
        expect(CURRENT_DOC_KEY).assertEqual('harmony_md_current');
      });
    });

    describe('MarkdownParser', () => {
      it('should_parse_heading_paragraph_and_quote', 0, () => {
        const blocks = parseMarkdown('# Title\nplain text\n> quote');

        expect(blocks.length).assertEqual(3);
        expect(blocks[0].type).assertEqual(BlockType.HEADING1);
        expect(blocks[0].spans[0].text).assertEqual('Title');
        expect(blocks[1].type).assertEqual(BlockType.PARAGRAPH);
        expect(blocks[1].spans[0].text).assertEqual('plain text');
        expect(blocks[2].type).assertEqual(BlockType.BLOCKQUOTE);
        expect(blocks[2].spans[0].text).assertEqual('quote');
      });

      it('should_parse_code_block_and_task_list', 0, () => {
        const blocks = parseMarkdown('```ts\nconst a = 1;\n```\n- [x] done\n- [ ] todo');

        expect(blocks.length).assertEqual(3);
        expect(blocks[0].type).assertEqual(BlockType.CODE_BLOCK);
        expect(blocks[0].language).assertEqual('ts');
        expect(blocks[0].spans[0].text).assertContain('const a = 1;');
        expect(blocks[1].type).assertEqual(BlockType.TASK_LIST);
        expect(blocks[1].checked!).assertTrue();
        expect(blocks[2].type).assertEqual(BlockType.TASK_LIST);
        expect(blocks[2].checked!).assertFalse();
      });

      it('should_parse_inline_styles', 0, () => {
        const blocks = parseMarkdown('**bold** *italic* `code` [site](https://example.com) ~~gone~~');
        const spans = blocks[0].spans;
        let italicCount = 0;
        let codeCount = 0;
        let linkCount = 0;
        let strikeCount = 0;
        let linkText = '';
        let linkUrl = '';

        for (let i = 0; i < spans.length; i++) {
          if (spans[i].style === TextStyle.ITALIC) {
            italicCount++;
          }
          if (spans[i].style === TextStyle.CODE) {
            codeCount++;
          }
          if (spans[i].style === TextStyle.LINK) {
            linkCount++;
            linkText = spans[i].text;
            linkUrl = spans[i].link ?? '';
          }
          if (spans[i].style === TextStyle.STRIKE) {
            strikeCount++;
          }
        }

        expect(blocks[0].type).assertEqual(BlockType.PARAGRAPH);
        expect(spans[0].style).assertEqual(TextStyle.BOLD);
        expect(spans[0].text).assertEqual('bold');
        expect(italicCount).assertEqual(1);
        expect(codeCount).assertEqual(1);
        expect(linkCount).assertEqual(1);
        expect(linkText).assertEqual('site');
        expect(linkUrl).assertEqual('https://example.com');
        expect(strikeCount).assertEqual(1);
      });

      it('should_count_words_by_character_length', 0, () => {
        expect(getWordCount('')).assertEqual(0);
        expect(getWordCount('Hello')).assertEqual(5);
        expect(getWordCount('你好世界')).assertEqual(4);
        expect(getWordCount('Hello\n世界')).assertEqual(8);
      });
    });

    describe('CommonConstants', () => {
      it('should_define_toolbar_buttons_consistently', 0, () => {
        expect(TOOLBAR_BUTTONS.length).assertEqual(11);
        expect(TOOLBAR_BUTTONS[0].label).assertEqual('标题');
        expect(TOOLBAR_BUTTONS[0].insertText).assertEqual('# ');
        expect(TOOLBAR_BUTTONS[3].insertText).assertEqual('`');
        expect(TOOLBAR_BUTTONS[10].insertText).assertEqual('\n---\n');
      });

      it('should_define_light_and_dark_theme_tokens', 0, () => {
        expect(LIGHT_THEME.background).assertEqual('#FFFFFF');
        expect(LIGHT_THEME.text).assertEqual('#1D1D1F');
        expect(DARK_THEME.background).assertEqual('#1D1D1F');
        expect(DARK_THEME.text).assertEqual('#F5F5F7');
        expect(LIGHT_THEME.primary === DARK_THEME.primary).assertFalse();
      });

      it('should_define_sync_status_values', 0, () => {
        expect(SyncStatus.SYNCED).assertEqual('synced');
        expect(SyncStatus.SYNCING).assertEqual('syncing');
        expect(SyncStatus.OFFLINE).assertEqual('offline');
      });
    });
  });
}
