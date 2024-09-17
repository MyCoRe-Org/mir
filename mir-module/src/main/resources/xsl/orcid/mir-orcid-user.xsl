<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exslt="http://exslt.org/common"
  extension-element-prefixes="exslt"
  exclude-result-prefixes="xsl">

  <!-- include Tokenizer template -->
  <xsl:import href="resource:xsl/coreFunctions.xsl"/>
  <xsl:import href="resource:xsl/orcid/mir-orcid.xsl"/>

  <xsl:param name="MCR.ORCID2.User.TrustedNameIdentifierTypes" select="''"/>
  <xsl:param name="currentUser" select="document('user:current')/user"/>
  <xsl:variable name="isGuestUser" select="$currentUser/@name = 'guest'"/>

  <xsl:variable name="userOrcidsXml">
    <xsl:if test="$isOrcidEnabled and not($isGuestUser)">
      <xsl:call-template name="extract-orcid-ids">
        <xsl:with-param name="userAttributes" select="$currentUser/attributes"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="userOrcids" select="exslt:node-set($userOrcidsXml)/str"/>

  <xsl:variable name="userIdsXml">
    <xsl:if test="$isOrcidEnabled and not($isGuestUser)">
      <xsl:call-template name="extract-user-ids">
        <xsl:with-param name="userAttributes" select="$currentUser/attributes"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="userIds" select="exslt:node-set($userIdsXml)/str"/>

  <xsl:variable name="hasLinkedOrcidCredential"
    select="$isOrcidEnabled
            and not($isGuestUser)
            and count($currentUser/attributes/attribute[starts-with(@name, 'orcid_credential')]) &gt; 0"/>

  <xsl:variable name="trustedIdTypesXml">
    <xsl:if test="$isOrcidEnabled">
      <xsl:call-template name="Tokenizer">
        <xsl:with-param name="string" select="$MCR.ORCID2.User.TrustedNameIdentifierTypes"/>
        <xsl:with-param name="delimiter" select="','"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="trustedIdTypes" select="exslt:node-set($trustedIdTypesXml)"/>

  <xsl:template name="extract-orcid-ids">
    <xsl:param name="userAttributes"/>
    <xsl:if test="$userAttributes and $userAttributes/attribute">
      <xsl:for-each select="$userAttributes/attribute[starts-with(@name, 'id_orcid')]">
        <str><xsl:value-of select="@value"/></str>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="extract-user-ids">
    <xsl:param name="userAttributes"/>
    <xsl:if test="$userAttributes and $userAttributes/attribute">
      <xsl:for-each select="$userAttributes/attribute[starts-with(@name, 'id_')]">
        <xsl:variable name="type" select="substring(@name, 4)"/>
        <str><xsl:value-of select="concat($type, ':', @value)"/></str>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="check-current-user-has-trusted-matching-id">
    <xsl:param name="nameIds"/>
    <xsl:variable name="currentUserMatchingTrustedIdsXml">
      <xsl:call-template name="get-matching-trusted-ids">
        <xsl:with-param name="idsA" select="$userIds"/>
        <xsl:with-param name="idsB" select="$nameIds"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="boolean(exslt:node-set($currentUserMatchingTrustedIdsXml)/str)"/>
  </xsl:template>

  <xsl:template name="get-matching-trusted-ids">
    <xsl:param name="idsA"/>
    <xsl:param name="idsB"/>
    <xsl:choose>
      <xsl:when test="count($trustedIdTypes) &gt; 0">
        <xsl:variable name="trustedIdsAXml">
          <xsl:call-template name="filter-trusted-ids">
            <xsl:with-param name="ids" select="$idsA"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="intersect-string-nodesets">
          <xsl:with-param name="listA" select="exslt:node-set($trustedIdsAXml)/str"/>
          <xsl:with-param name="listB" select="$idsB"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="filter-trusted-ids">
    <xsl:param name="ids"/>
    <xsl:if test="count($trustedIdTypes) &gt; 0">
      <xsl:for-each select="$ids[substring-before(., ':') = $trustedIdTypes]">
        <str><xsl:value-of select="."/></str>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="intersect-string-nodesets">
    <xsl:param name="listA"/>
    <xsl:param name="listB"/>
    <xsl:for-each select="$listB[. = $listA]">
      <str><xsl:value-of select="."/></str>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
