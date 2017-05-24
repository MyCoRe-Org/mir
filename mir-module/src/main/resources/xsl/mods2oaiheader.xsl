<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns="http://www.openarchives.org/OAI/2.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"

  exclude-result-prefixes="mods"
>

<xsl:output method="xml" encoding="UTF-8" indent="yes" />

<xsl:param name="MCR.OAIDataProvider.OAI2.RepositoryIdentifier" />
<xsl:param name="MCR.OAIDataProvider.OAI2.MapSetToQuery.open_access" />
<xsl:param name="MCR.OAIDataProvider.OAI2.MapSetToQuery.driver" />
<xsl:param name="MCR.OAIDataProvider.OAI2.MapSetToQuery.openaire" />
<xsl:param name="MCR.OAIDataProvider.OAI2.MapSetToQuery.ec_fundedresources" />
<xsl:param name="MCR.OAIDataProvider.OAI2.MapSetToQuery.xmetadissplus" />


<xsl:template match="/">
  <header>
    <xsl:apply-templates select="mycoreobject" mode="header" />
  </header>
</xsl:template>

<xsl:template match="mycoreobject" mode="header">

  <identifier>
    <xsl:text>oai:</xsl:text>
    <xsl:value-of select="$MCR.OAIDataProvider.OAI2.RepositoryIdentifier" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="@ID" />
  </identifier>

  <datestamp>
    <xsl:value-of select="substring-before(service/servdates/servdate[@type='modifydate'],'T')" />
  </datestamp>

  <!-- check for the following sets: doc-type,open_access,openaire,driver,ec_fundedresources,GENRE,ddc -->
  <setSpec><xsl:value-of select="concat('doc-type:', substring-after(metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@generator='mir_genres2diniPublType-mycore']/@valueURI,'#'))" /></setSpec>
  <setSpec><xsl:value-of select="concat('GENRE:', substring-after(metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI,'#'))" /></setSpec>

  <xsl:choose>
    <xsl:when test="metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@authority='ddc']">
      <setSpec><xsl:value-of select="concat('ddc:', metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@authority='ddc'])" /></setSpec>
    </xsl:when>
    <xsl:when test="metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@authority='sdnb']">
      <setSpec><xsl:value-of select="concat('ddc:', metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@authority='sdnb'])" /></setSpec>
    </xsl:when>
  </xsl:choose>

  <xsl:variable name="isOpenAccess" xmlns:encoder="xalan://java.net.URLEncoder"
                select="document(concat('solr:q=',encoder:encode(concat($MCR.OAIDataProvider.OAI2.MapSetToQuery.open_access, ' AND id:', @ID)), '&amp;rows=0'))/response/result/@numFound" />
  <xsl:if test="$isOpenAccess &gt; 0">
    <setSpec>open_access</setSpec>
  </xsl:if>

  <xsl:variable name="isDriver" xmlns:encoder="xalan://java.net.URLEncoder"
                select="document(concat('solr:q=',encoder:encode(concat($MCR.OAIDataProvider.OAI2.MapSetToQuery.driver, ' AND id:', @ID)), '&amp;rows=0'))/response/result/@numFound" />
  <xsl:if test="$isDriver &gt; 0">
    <setSpec>driver</setSpec>
  </xsl:if>

  <xsl:variable name="isOpenAire" xmlns:encoder="xalan://java.net.URLEncoder"
                select="document(concat('solr:q=',encoder:encode(concat($MCR.OAIDataProvider.OAI2.MapSetToQuery.openaire, ' AND id:', @ID)), '&amp;rows=0'))/response/result/@numFound" />
  <xsl:if test="$isOpenAire &gt; 0">
    <setSpec>driver</setSpec>
  </xsl:if>

  <xsl:variable name="isEC_FundedResources" xmlns:encoder="xalan://java.net.URLEncoder"
                select="document(concat('solr:q=',encoder:encode(concat($MCR.OAIDataProvider.OAI2.MapSetToQuery.ec_fundedresources, ' AND id:', @ID)), '&amp;rows=0'))/response/result/@numFound" />
  <xsl:if test="$isEC_FundedResources &gt; 0">
    <setSpec>driver</setSpec>
  </xsl:if>

  <xsl:variable name="isXMetaDissPlus" xmlns:encoder="xalan://java.net.URLEncoder"
                select="document(concat('solr:q=',encoder:encode(concat($MCR.OAIDataProvider.OAI2.MapSetToQuery.xmetadissplus, ' AND id:', @ID)), '&amp;rows=0'))/response/result/@numFound" />
  <xsl:if test="$isXMetaDissPlus &gt; 0">
    <setSpec><xsl:value-of select="concat('doc-type:', substring-after(metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[contains(@authorityURI,'XMetaDissPlusThesisLevel')]/@valueURI,'#'))" /></setSpec>
  </xsl:if>

</xsl:template>

</xsl:stylesheet>
