import cdk = require('@aws-cdk/core');
import { StaticWebsiteStack, IStaticWebsiteProps } from './StaticWebsiteStack';
const config = require('../config-cdk-hoodie.json');

export class HoodieWebsiteStack extends StaticWebsiteStack {
  constructor(scope: cdk.App, id: string ) {
    const props: IStaticWebsiteProps = {
      websiteDistPath: '../dist',
      deploymentVersion: '1.0.0',
      certificateArn: config.certificateArn,
      domainNames: [config.domainNames],
      resourcePrefix: config.resourcePrefix,
      indexDocument: 'index.html',
    };

    super(scope, id, props);
  }
}
