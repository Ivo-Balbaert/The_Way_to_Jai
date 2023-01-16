#import "Basic";
Mail :: #import "Mail";

USERNAME :: "put_username_here";
PASSWORD :: "put_password_here";

SMTP_HOST :: "name_of_smtp_host";
SMTP_PORT :: "port_number, usually 587";

FROM_EMAIL :: "sender_address";
EMAIL_SUBJECT :: "Testing email!";

EMAIL_BODY :: #string DONE
This is the body of the mail:
This is the message:

    %1

Best regards,
DONE


send_an_email :: (address: string, key: string) -> bool {
    body := sprint(EMAIL_BODY, key);
    defer free(body);

    smtp : Mail.Mail_Server;

    smtp.host       = SMTP_HOST;
    smtp.port       = SMTP_PORT;
    smtp.enable_ssl = true;
    smtp.username   = USERNAME;
    smtp.password   = PASSWORD;

    m : Mail.Mail_Message;

    addresses: [..] string;
    array_add(*addresses, address);
    
    m.from        = FROM_EMAIL;
    m.to          = addresses;
    m.subject     = EMAIL_SUBJECT;
    m.body        = body;
    m.html        = false;

    result := Mail.mail_send(smtp, m);
    return result;
}

main :: () {
    email := "to_email_address";
    key := "THE KEY";
    success := send_an_email(email, key);
    if success  print ("Email sent!");
}

