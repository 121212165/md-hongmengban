
import { describe, it, expect, beforeAll, afterAll } from '@ohos.hypium';
import { FileService } from '../main/ets/services/FileService';
import { Document } from '../main/ets/models/DocumentModel';

export default function fileServiceTest() {
  describe('FileService测试集', () => {
    let fileService: FileService;
    let testDocId: string;

    beforeAll(async () => {
      // 获取单例实例
      fileService = FileService.getInstance();
    });

    // 测试getInstance单例
    describe('单例模式', () => {
      it('should_return_same_instance', 0, (): void => {
        const instance1 = FileService.getInstance();
        const instance2 = FileService.getInstance();
        // 同一实例
        expect(instance1).assertEqual(instance2);
      });
    });

    // 测试文档操作 - 需要先mock初始化
    describe('文档操作', () => {
      // 跳过需要上下文的测试，仅测试纯逻辑
      it('should_create_new_document', 0, (): void => {
        // 创建文档应该返回Document对象
        const doc = fileService.createDocument('test.md', '# Test');
        expect(doc).assertNotNull();
        expect(doc.name).assertEqual('test.md');
        expect(doc.content).assertEqual('# Test');
        testDocId = doc.id;
      });

      it('should_get_all_documents', 0, (): void => {
        const docs = fileService.getDocuments();
        expect(docs.length).assertLarger(0);
      });

      it('should_get_current_docId', 0, (): void => {
        const currentId = fileService.getCurrentDocId();
        expect(currentId).assertNotNull();
      });

      it('should_open_document', 0, (): void => {
        const doc = fileService.openDocument(testDocId);
        expect(doc).assertNotNull();
      });

      it('should_save_document_content', 0, (): void => {
        const result = fileService.saveDocumentContent(testDocId, '# Updated content');
        expect(result).assertTrue();
      });

      it('should_save_document_name', 0, (): void => {
        const result = fileService.saveDocumentName(testDocId, 'renamed.md');
        expect(result).assertTrue();
      });

      it('should_get_current_document', 0, (): void => {
        const doc = fileService.getCurrentDocument();
        expect(doc).assertNotNull();
      });

      it('should_set_current_document', 0, (): void => {
        fileService.setCurrentDocument(testDocId);
        // 设置后应该能够获取
        const currentId = fileService.getCurrentDocId();
        expect(currentId).assertEqual(testDocId);
      });
    });

    // 测试格式时间函数
    describe('formatRelativeTime', () => {
      it('should_format_just_now', 0, (): void => {
        const now = Date.now();
        const result = fileService.formatRelativeTime(now);
        expect(result).assertEqual('刚刚');
      });

      it('should_format_minutes_ago', 0, (): void => {
        const fiveMinutesAgo = Date.now() - 5 * 60 * 1000;
        const result = fileService.formatRelativeTime(fiveMinutesAgo);
        expect(result).assertEqual('5分钟前');
      });

      it('should_format_hours_ago', 0, (): void => {
        const twoHoursAgo = Date.now() - 2 * 60 * 60 * 1000;
        const result = fileService.formatRelativeTime(twoHoursAgo);
        expect(result).assertEqual('2小时前');
      });

      it('should_format_date', 0, (): void => {
        const yesterday = Date.now() - 25 * 60 * 60 * 1000;
        const result = fileService.formatRelativeTime(yesterday);
        // 应该返回月/日格式
        expect(result).assertContain('/');
      });
    });

    // 测试删除文档
    describe('删除文档', () => {
      it('should_delete_document', 0, (): void => {
        // 创建一个可删除的文档
        const doc = fileService.createDocument('delete_me.md', 'to be deleted');
        const docId = doc.id;
        const result = fileService.deleteDocument(docId);
        expect(result).assertTrue();
      });

      it('should_handle_delete_nonexistent', 0, (): void => {
        const result = fileService.deleteDocument('nonexistent_id');
        expect(result).assertFalse();
      });
    });
  });
}