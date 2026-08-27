// client-plugin/index.tsx — DSH cordis 客户端插件入口
// v1.7 关键修正（修后端 B7）：
//   成对调用：ctx.slots.inject(key, () => ctx.slots.register({...}, Component))
//   4 个真实 slot：conversation.chat.turnTail / sidebar.footer.action / settings.section / conversation.view

import { BadgePopover } from './BadgePopover';
import { SidebarFooter } from './SidebarFooter';
import { SettingsSection } from './SettingsSection';
import { ArtifactViewer } from './ArtifactViewer';

export default {
  name: 'harness-kit-client',
  version: '1.7.0',

  setup(ctx) {
    // C 形态：每个 turn 末尾浮小徽章（chain slot：用 select 选举）
    ctx.slots.inject('conversation.chat.turnTail', () =>
      ctx.slots.register(
        { name: 'conversation.chat.turnTail', select: (props: any) => <BadgePopover {...props} /> },
        null  // chain slot: component via select(), not direct render
      )
    );

    // 全局徽章（single slot）
    ctx.slots.inject('sidebar.footer.action', () =>
      ctx.slots.register(
        { name: 'sidebar.footer.action', priority: 0 },
        <SidebarFooter />
      )
    );

    // 设置页资产管理 section（list slot：id 必须）
    ctx.slots.inject('settings.section', () =>
      ctx.slots.register(
        { name: 'settings.section', id: 'harness', order: 50, label: 'Harness' },
        <SettingsSection />
      )
    );

    // B 形态：details 列 view tab（keyed slot：id 必须）
    ctx.slots.inject('conversation.view', () =>
      ctx.slots.register(
        { name: 'conversation.view', key: 'harness-artifacts', label: 'Artifacts' },
        <ArtifactViewer />
      )
    );
  },
};
