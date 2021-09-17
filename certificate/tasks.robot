*** Settings ***
Documentation   This is a simple robot created fot the level 2 certificate of Robocorp. 
Library    RPA.Browser
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.Tables
Library    RPA.HTTP
Library    OperatingSystem
Library    Collections
Library    RPA.Robocorp.Vault
Library    RPA.Dialogs



*** Variables ***
${form}=    https://robotsparebinindustries.com/#/robot-order
${head}=    head
${radio}=    body
${legs}=    /html/body/div/div/div[1]/div/div[1]/form/div[3]/input
${address}=    address
${preview}=    preview
${order}=    order
${receipt_id}=    receipt


*** Keywords ***
Open the order website

    ${sheet}=  Get Orders
    Open Available Browser    ${form}
    ${rows}  ${columns}=    Get table dimensions    ${sheet}
    
    FOR    ${i}    IN RANGE   ${rows}
        
        Click Button    css: #root > div > div.modal > div > div > div > div > div > button.btn.btn-dark    
        Fill the form    ${sheet}[${i}]
        Create Directory    output/images
        Create Directory    output/receipts
        Create Directory    output/text        
        Screenshot     id: robot-preview-image    output/images/${sheet}[${i}][0].png
        ${html}=    Get Element Attribute    id: ${receipt_id}    outerHTML
        Html To Pdf        ${html}    output/text/text${sheet}[${i}][0].pdf
        Open Pdf    output/text/text${sheet}[${i}][0].pdf
        Add Watermark Image To Pdf    output/images/${sheet}[${i}][0].png    output/receipts/receipt${sheet}[${i}][0].pdf
        Close All Pdfs
        Click Button    id: order-another
    END
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/receipts.zip
    Archive Folder With Zip
    ...    output/receipts
    ...    ${zip_file_name}
    

*** Keywords ***
Get Orders
    ${csv}=    Get Secret    csv_url
    Add heading    Paste url of "orders.csv". It is compared to correct url in the Vault
    Add text input    url    label=Insert url
    ...    label=Url
    ...    placeholder=Paste Url
    ...    rows=1
    ${result}=    Run dialog
    Should Be Equal As Strings   ${result}[url]    ${csv}[csv]    msg=Url is not correct.
        Download    ${csv}[csv]  target_file=output/orders.csv    overwrite=True
        ${Orders}=    Read table from CSV    output/orders.csv    header=True
        Return From Keyword    ${Orders}
   
  



*** Keywords ***
Fill the form
    [Arguments]    ${row}
    Select From List By Index    id: ${head}    ${row}[1]
    Select Radio Button    ${radio}   ${row}[2]
    Input Text    xpath: ${legs}    ${row}[3]  
    Input Text    id: ${address}    ${row}[4]  
    Click Button    id: ${preview}
    Wait Until Keyword Succeeds    2min    10ms    Order
    
*** Keywords ***
Order
    Click Button    id: ${order}
    Wait Until Page Contains Element    id: ${receipt_id}
    


*** Tasks ***
Open the order website
    Open the order website