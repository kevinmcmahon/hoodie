#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { HoodieWebsiteStack } from '../lib/HoodieWebsiteStack';

const app = new cdk.App();
new HoodieWebsiteStack(app, 'HoodieWebsiteStack');
