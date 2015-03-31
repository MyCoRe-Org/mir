<?xml version="1.0" encoding="UTF-8"?>

<!-- XSL to search for related objects -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:encoder="xalan://java.net.URLEncoder" exclude-result-prefixes="xsl xalan i18n encoder"
>
  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:param name="RequestURL" />

  <xsl:variable name="PageID" select="'select-relatedItem'" />

  <xsl:variable name="PageTitle" select="i18n:translate('mir.relatedItemSelect.title')" />

  <!-- ========== XED Subselect detection ========== -->
  <xsl:variable name="xedSession">
    <xsl:call-template name="UrlGetParam">
      <xsl:with-param name="url" select="$RequestURL" />
      <xsl:with-param name="par" select="'_xed_subselect_session'" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="/response/result|lst[@name='grouped']/lst[@name='returnId']" priority="20">
    <xsl:variable name="cancelURL">
      <xsl:value-of select="concat($ServletsBaseURL,'XEditor?_xed_submit_return= ')" />
      <xsl:value-of select="concat('&amp;_xed_session=',encoder:encode($xedSession,'UTF-8'))" />
    </xsl:variable>
    <p>
      Bitte wählen Sie nachstehend die Publikation aus, die Sie einfügen wollen:
    </p>
    <form method="post" action="{$cancelURL}">
      <input value="{i18n:translate('component.user2.button.cancelSelect')}" class="btn btn-default" type="submit" />
    </form>
    <ul>
      <xsl:apply-templates select="arr[@name='groups']/lst[str/@name='groupValue']" mode="subselect" />
    </ul>
  </xsl:template>

  <xsl:template match="lst" mode="subselect">
    <xsl:variable name="id" select="str[@name='groupValue']" />
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat($ServletsBaseURL,'XEditor?_xed_submit_return= ')" />
          <xsl:value-of select="concat('&amp;_xed_session=',encoder:encode($xedSession,'UTF-8'))" />
          <xsl:value-of select="concat('&amp;@xlink:href=',encoder:encode($id,'UTF-8'))" />
        </xsl:attribute>
        <xsl:value-of select="result/doc/arr[@name='mods.title']/str" />
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
