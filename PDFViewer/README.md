# **************  Default ORG: LWC ******************

    sfdx force:org:display

# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

## Unlocked package
- Create package: 
    sfdx force:package:create -n CGS_PDFViewer-01 -d "PDF viewer" -r force-app -t Unlocked -v DevHub

- List all packages: 
    sfdx force:package:list

- Create Package version
    update sfdx-project.json with Version name/number
    
    sfdx force:package:version:create -p CGS_PDFViewer-01 -d force-app -k CGS1234 --wait 10 -v DevHub

    after packate version created. Note down:
        
        Successfully created the package version [08c3i000000L0P7AAK]. Subscriber Package Version Id: 04t3i000002al6hAAA
        Package Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t3i000002al6hAAA
        As an alternative, you can use the "sfdx force:package:install" command.

        Using emailTemplate:

- installing package
    sfdx force:package:install -u GIFter --wait 10 --package 04t3i000001SIykAAG -k CGS1234 --noprompt

- open org: 
    sfdx force:org:open -u GIFter
