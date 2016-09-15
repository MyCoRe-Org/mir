<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="DefaultLang" />
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="MCR.mir-module.NewUserMail" />
  <xsl:param name="MCR.mir-module.MailSender" />
  <xsl:variable name="newline" select="'&#xA;'" />

  <xsl:template match="/">
    <email>
      <from>
        <xsl:value-of select="$MCR.mir-module.MailSender" />
      </from>
      <xsl:apply-templates select="/*" mode="email" />
    </email>
  </xsl:template>

  <xsl:template match="user" mode="email">
    <to>
      <xsl:value-of select="$MCR.mir-module.NewUserMail" />
    </to>
    <subject>
      Eine neue Benutzerkennung wurde angelegt!
    </subject>
    <body>
      <xsl:text>Es wurde soeben eine neue Benutzerkennung angelegt.</xsl:text>
      <xsl:value-of select="$newline" />
      <xsl:value-of select="$newline" />
      <xsl:value-of select="concat('Benutzerkennung : ',@name,' (',@realm,')',$newline)" />
      <xsl:value-of select="concat('Name            : ',realName,$newline)" />
      <xsl:value-of select="concat('E-Mail          : ',eMail,$newline)" />
      <xsl:value-of select="concat('Link            : ',$ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)" />
    </body>
  </xsl:template>
</xsl:stylesheet>
