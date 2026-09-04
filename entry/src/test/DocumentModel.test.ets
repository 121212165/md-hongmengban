
import { describe, it, expect, beforeAll, afterAll } from '@ohos.hypium';
import { Document, createDocument, DOCUMENTS_KEY, CURRENT_DOC_KEY } from '../main/ets/models/DocumentModel';

export default function documentModelTest() {
  describe('DocumentModel测试集', () => {
    // 测试createDocument函数
    describe('createDocument', () => {
      it('should_create_document_with_default_content', 0, (): void => {
        const doc = createDocument('test.md');
        expect(doc.id).assertEqual('doc_' + Date.now().toString().substring(0, 10));
        expect(doc.name).assertEqual('test.md');
        expect(doc.content).assertEqual('');
        expect(doc.createdAt).assertLarger(0);
        expect(doc.updatedAt).assertLarger(0);
      });

      it('should_create_document_with_content', 0, (): void => {
        const doc = createDocument('test.md', '# Hello');
        expect(doc.content).assertEqual('# Hello');
      });

      it('should_append_md_extension', 0, (): void => {
        const doc = createDocument('test');
        expect(doc.name).assertEqual('test.md');
      });

      it('should_keep_md_extension_if_already_present', 0, (): void => {
        const doc = createDocument('test.md');
        expect(doc.name).assertEqual('test.md');
      });
    });

    // 测试常量
    describe('常量测试', () => {
      it('should_have_documents_key', 0, (): void => {
        expect(DOCUMENTS_KEY).assertEqual('harmony_md_documents');
      });

      it('should_have_current_doc_key', 0, (): void => {
        expect(CURRENT_DOC_KEY).assertEqual('harmony_md_current');
      });
    });

    // 测试Document接口属性
    describe('Document接口属性', () => {
      it('should_have_required_properties', 0, (): void => {
        const doc: Document = {
          id: 'test_001',
          name: 'test.md',
          content: 'test content',
          createdAt: Date.now(),
          updatedAt: Date.now()
        };
        expect(doc.id).assertEqual('test_001');
        expect(doc.name).assertEqual('test.md');
        expect(doc.content).assertEqual('test content');
        expect(typeof doc.createdAt).assertEqual('number');
        expect(typeof doc.updatedAt).assertEqual('number');
      });
    });
  });
}