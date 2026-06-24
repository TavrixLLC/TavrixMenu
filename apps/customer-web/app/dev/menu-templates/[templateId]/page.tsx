import { notFound } from 'next/navigation';
import { PublicMenuTemplateView } from '../../../components/PublicMenuTemplateView';
import { publicMenuTemplates } from '../../../lib/menu-templates';
import { demoLoyalty, demoMenu } from '../preview-data';

type TemplatePreviewPageProps = {
  params: Promise<{
    templateId: string;
  }>;
};

export default async function SingleMenuTemplatePreviewPage({ params }: TemplatePreviewPageProps) {
  const { templateId } = await params;
  const template = publicMenuTemplates.find((candidate) => candidate.id === templateId);

  if (!template) {
    notFound();
  }

  return (
    <PublicMenuTemplateView
      menu={{
        ...demoMenu,
        business: {
          ...demoMenu.business,
          menuTemplateId: template.id
        }
      }}
      template={template}
      loyaltyContext={demoLoyalty}
    />
  );
}
