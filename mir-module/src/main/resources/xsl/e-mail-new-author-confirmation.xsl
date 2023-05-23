<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="DefaultLang"/>
    <xsl:param name="WebApplicationBaseURL"/>
    <xsl:param name="ServletsBaseURL"/>
    <xsl:param name="MCR.mir-module.NewUserMail"/>
    <xsl:param name="MCR.mir-module.MailSender"/>
    <xsl:param name="MIR.SelfRegistration.EmailVerification.setDisabled"/>
    <xsl:variable name="newline" select="'&#xA;'"/>

    <xsl:template match="/">
        <email>
            <from>
                <xsl:value-of select="$MCR.mir-module.MailSender"/>
            </from>
            <xsl:apply-templates select="/*" mode="email"/>
        </email>
    </xsl:template>

    <xsl:template match="user" mode="email">
        <to>
            <xsl:value-of select="$MCR.mir-module.NewUserMail"/>
        </to>
        <subject>
            Der Benutzer hat seine E-Mail-Adresse bestätigt!
        </subject>
        <body>
            <xsl:text>Der Benutzer hat soeben seine E-Mail-Adresse bestätigt.</xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:value-of select="$newline"/>
            <xsl:value-of select="concat('Benutzerkennung : ',@name,' (',@realm,')',$newline)"/>
            <xsl:value-of select="concat('Name            : ',realName,$newline)"/>
            <xsl:value-of select="concat('E-Mail          : ',eMail,$newline)"/>
            <xsl:value-of
                    select="concat('Link            : ',$ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)"/>
            <xsl:value-of select="$newline"/>

            <xsl:choose>
                <xsl:when
                        test="$MIR.SelfRegistration.EmailVerification.setDisabled = 'true' or  $MIR.SelfRegistration.EmailVerification.setDisabled = 'TRUE'">
                    <xsl:text>Bitte überprüfen Sie die erstellte Benutzerkennung und heben Sie die Sperrung nach Möglichkeit auf.</xsl:text>
                    <xsl:value-of select="$newline"/>
                </xsl:when>
            </xsl:choose>
        </body>
    </xsl:template>
</xsl:stylesheet>
