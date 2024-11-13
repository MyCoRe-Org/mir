<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl" version="1.0">

  <xsl:import href="resource:xsl/coreFunctions.xsl"/>

  <xsl:param name="MCR.ORCID2.User.TrustedNameIdentifierTypes"/>
  <xsl:param name="trustedIdTypesXml">
    <xsl:call-template name="Tokenizer">
      <xsl:with-param name="string" select="$MCR.ORCID2.User.TrustedNameIdentifierTypes"/>
      <xsl:with-param name="delimiter" select="','"/>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="trustedIdTypes" select="exsl:node-set($trustedIdTypesXml)"/>
  <xsl:param name="MCR.ORCID2.Work.PublishStates"/>
  <xsl:param name="publishStatesXml">
    <xsl:call-template name="Tokenizer">
      <xsl:with-param name="string" select="$MCR.ORCID2.Work.PublishStates"/>
      <xsl:with-param name="delimiter" select="','"/>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="publishStates" select="exsl:node-set($publishStatesXml)"/>

  <xsl:template name="checkElementContainsNodeSet">
    <xsl:param name="nodeSet"/>
    <xsl:param name="element"/>
    <xsl:choose>
      <xsl:when test="$nodeSet[.=$element]">
        <xsl:value-of select="'true'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'false'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="checkIdIsTrusted">
    <xsl:param name="id"/>
    <xsl:variable name="type" select="substring-before($id,':')"/>
    <xsl:call-template name="checkElementContainsNodeSet">
      <xsl:with-param name="nodeSet" select="$trustedIdTypes"/>
      <xsl:with-param name="element" select="$type"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="checkStateIsAllowedToPublish">
    <xsl:param name="state"/>
    <xsl:call-template name="checkElementContainsNodeSet">
      <xsl:with-param name="nodeSet" select="$publishStates"/>
      <xsl:with-param name="element" select="$state"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template name="intersectLists">
    <xsl:param name="listA"/>
    <xsl:param name="listB"/>
    <xsl:for-each select="$listB">
      <xsl:variable name="currentItem" select="."/>
      <xsl:if test="$listA[.=$currentItem]">
        <str>
          <xsl:value-of select="."/>
        </str>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="filterTrustedIds">
    <xsl:param name="ids"/>
    <xsl:for-each select="$ids">
      <xsl:variable name="idIsTrusted">
        <xsl:call-template name="checkIdIsTrusted">
          <xsl:with-param name="id" select="."/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$idIsTrusted='true'">
        <str>
          <xsl:value-of select="."/>
        </str>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getMatchingTrustedIds">
    <xsl:param name="idsA"/>
    <xsl:param name="idsB"/>
    <xsl:choose>
      <xsl:when test="count($trustedIdTypes) &gt; 0">
        <xsl:variable name="trustedIdsAXml">
          <xsl:call-template name="filterTrustedIds">
            <xsl:with-param name="ids" select="$idsA"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="intersectLists">
          <xsl:with-param name="listA" select="exsl:node-set($trustedIdsAXml)"/>
          <xsl:with-param name="listB" select="$idsB"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="extractUserIdsFromUserAttributes">
    <xsl:param name="userAttributes"/>
    <xsl:for-each select="$userAttributes/attribute[starts-with(@name, 'id_')]">
      <xsl:variable name="type" select="substring(./@name, 4)"/>
      <str>
        <xsl:value-of select="concat($type,':',./@value)"/>
      </str>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="extractOrcidsFromUserAttributes">
    <xsl:param name="userAttributes"/>
    <xsl:for-each select="$userAttributes/attribute[starts-with(@name, 'id_orcid')]">
      <str>
        <xsl:value-of select="./@value"/>
      </str>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>