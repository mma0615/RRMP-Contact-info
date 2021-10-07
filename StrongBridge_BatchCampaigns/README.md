# Salesforce App

## Dev, Build and Test

## Resources

## Description of Files and Directories

## Issues

## Deploy APEX Classes
Production: AEReportProd
sfdx force:source:deploy -m ApexClass:batchCampaigns -l RunLocalTests -u AEReportProd

Sandbox: AEReportSand
sfdx force:source:deploy -m ApexClass:batchCampaigns -l RunLocalTests -u AEReportSand