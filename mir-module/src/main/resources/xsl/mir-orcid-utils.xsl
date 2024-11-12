<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common">

  <xsl:import href="resource:xsl/coreFunctions.xsl"/>

  <xsl:param name="MCR.ORCID2.User.TrustedNameIdentifierTypes"/>
  <xsl:param name="trustedIdTypesXml">
    <xsl:call-template name="Tokenizer">
      <xsl:with-param name="string" select="$MCR.ORCID2.User.TrustedNameIdentifierTypes"/>
      <xsl:with-param name="delimiter" select="','"/>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="trustedIdTypes" select="exslt:node-set($trustedIdTypesXml)"/>
  <xsl:param name="MCR.ORCID2.Work.PublishStates"/>
  <xsl:param name="publishStatesXml">
    <xsl:call-template name="Tokenizer">
      <xsl:with-param name="string" select="$MCR.ORCID2.Work.PublishStates"/>
      <xsl:with-param name="delimiter" select="','"/>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="publishStates" select="exslt:node-set($publishStatesXml)"/>

  <xsl:template name="checkIdIsTrusted">
    <xsl:param name="id"/>
    <xsl:variable name="type" select="substring-after(.,':')"/>
    <xsl:choose>
      <xsl:when test="$trustedIdTypes[contains(text(), $type)]">
        <xsl:value-of select="'true'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'false'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="checkStateIsAllowedToPublish">
    <xsl:param name="state"/>
    <xsl:choose>
      <xsl:when test="$publishStates[contains(text(), $state)]">
        <xsl:value-of select="'true'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'false'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
  <xsl:template name="intersectLists">
    <xsl:param name="listA"/>
    <xsl:param name="listB"/>
    <xsl:for-each select="$listB">
      <xsl:if test="$listA[contains(text(), .)]">
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
      <xsl:when test="count($trustedIdTypes) &gt; 0 or count($idsA) &gt; 0 or count($idsB) &gt; 0">
        <xsl:variable name="trustedIdsAXml">
          <xsl:for-each select="idsA">
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
        </xsl:variable>
        <xsl:call-template name="intersectLists">
          <xsl:with-param name="listA" select="exslt:node-set($trustedIdsAXml)"/>
          <xsl:with-param name="listB" select="$idsB"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="checkMatchingTrustedIdExists">
    <xsl:param name="idsA"/>
    <xsl:param name="idsB"/>
    <xsl:choose>
      <xsl:when test="count($trustedIdTypes) &gt; 0 or count($idsA) &gt; 0 or count($idsB) &gt; 0">
        <xsl:variable name="matchingTrustedIdsXml">
          <xsl:call-template name="getMatchingTrustedIds">
            <xsl:with-param name="idsA" select="$idsA"/>
            <xsl:with-param name="idsB" select="$idsB"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="count(exslt:node-set($matchingTrustedIdsXml)/str) &gt; 0"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'false'"/>
      </xsl:otherwise>
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