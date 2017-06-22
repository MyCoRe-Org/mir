<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns="http://www.openarchives.org/OAI/2.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<xsl:template match="/">
  <record>
    <metadata>
      <xsl:apply-templates select="mycoreobject" mode="metadata" />
    </metadata>
  </record>
</xsl:template>

</xsl:stylesheet>
