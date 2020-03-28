import cdk = require('@aws-cdk/core');
import {
  CloudFrontWebDistribution,
  CloudFrontWebDistributionProps,
  OriginAccessIdentity,
} from '@aws-cdk/aws-cloudfront'
import { Bucket } from '@aws-cdk/aws-s3';
import { BucketDeployment, Source } from '@aws-cdk/aws-s3-deployment';
import * as semver from 'semver';

export class StaticWebsiteStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, staticWebsiteConfig: IStaticWebsiteProps) {
    super(scope, id, undefined);

    const resourcePrefix = staticWebsiteConfig.resourcePrefix;
    const deploymentVersion = semver.inc(staticWebsiteConfig.deploymentVersion, 'patch') || '1.0.0';
    const originPath = deploymentVersion.replace(/\./g, '_');

    const sourceBucket = new Bucket(this, `S3BucketForWebsite`, {
      websiteIndexDocument: staticWebsiteConfig.indexDocument || 'index.html',
      bucketName: `${resourcePrefix}-website`,
    });

    new BucketDeployment(this, 'DeployWebsite', {
      sources: [Source.asset(staticWebsiteConfig.websiteDistPath)],
      destinationBucket: sourceBucket,
      destinationKeyPrefix: originPath,
    });

    const oai = new OriginAccessIdentity(this, `CloudFrontOIA`,{
      comment: `OAI for ${resourcePrefix} website.`
    });
    sourceBucket.grantRead(oai);
    
    let cloudFrontDistProps: CloudFrontWebDistributionProps;

    if (staticWebsiteConfig.certificateArn) {
      cloudFrontDistProps = {
        originConfigs: [
          {
            s3OriginSource: {
              s3BucketSource: sourceBucket,
              originAccessIdentity: oai
            },
            behaviors: [ {isDefaultBehavior: true}],
            originPath: `/${originPath}`,
          }
        ],
        aliasConfiguration: {
          acmCertRef: staticWebsiteConfig.certificateArn,
          names: staticWebsiteConfig.domainNames || []
        }
      };
    } else {
      cloudFrontDistProps = {
        originConfigs: [
          {
            s3OriginSource: { s3BucketSource: sourceBucket },
            behaviors: [ {isDefaultBehavior: true}],
            originPath: `/${originPath}`,
          }
        ]
      };
    }

    new CloudFrontWebDistribution(this, `${resourcePrefix}-cloudfront`, cloudFrontDistProps);
  }
}

export interface IStaticWebsiteProps {
  websiteDistPath: string;
  deploymentVersion: string
  certificateArn?: string;
  domainNames?: Array<string>;
  resourcePrefix: string;
  indexDocument?: string;
}
