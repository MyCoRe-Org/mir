<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns="http://www.openarchives.org/OAI/2.0/provenance"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/provenance http://www.openarchives.org/OAI/2.0/provenance.xsd"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<xsl:output method="xml" encoding="UTF-8" indent="yes" />

<xsl:param name="MCR.OAIDataProvider.OAI2.RepositoryIdentifier" />

<xsl:template match="/">
  <about>
    <xsl:apply-templates select="mycoreobject" mode="about" />
  </about>
</xsl:template>

<xsl:template match="mycoreobject" mode="about">

   <provenance>
     <!-- TODO: add attribute harvestDate="2012-09-17T14:58:36Z" -->
     <originDescription altered="true">
       <baseURL><xsl:value-of select="concat($ServletsBaseURL, 'OAIDataProvider')" /></baseURL>
       <identifier>
         <xsl:text>oai:</xsl:text>
         <xsl:value-of select="$MCR.OAIDataProvider.OAI2.RepositoryIdentifier" />
         <xsl:text>:</xsl:text>
         <xsl:value-of select="@ID" />
       </identifier>
       <datestamp>
         <xsl:value-of select="substring-before(service/servdates/servdate[@type='modifydate'],'T')" />
       </datestamp>
       <metadataNamespace>
         http://www.openarchives.org/OAI/2.0/oai_dc/
       </metadataNamespace>
     </originDescription>
   </provenance>

</xsl:template>

</xsl:stylesheet>
