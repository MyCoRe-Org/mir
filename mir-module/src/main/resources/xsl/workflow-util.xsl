<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:exslt="http://exslt.org/common"
                version="1.0" exclude-result-prefixes="i18n exslt">

  <xsl:template name="listStatusChangeOptions">
    <xsl:param name="class"/>

    <xsl:variable name="statusClassification" select="document('classification:metadata:-1:children:state')"/>
    <xsl:variable name="currentStatus" select="/mycoreobject/service/servstates/servstate[@classid='state']/@categid"/>
    <xsl:variable name="allowedNext"
                  select="normalize-space($statusClassification//category[@ID=$currentStatus]/label[@xml:lang='x-next']/@text)"/>
    <xsl:if test="string-length($allowedNext)&gt;0 and $allowedNext!='null'">
      <xsl:variable name="token">
        <xsl:call-template name="Tokenizer">
          <xsl:with-param name="string" select="$allowedNext"/>
          <xsl:with-param name="delimiter" select="','"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="id" select="/mycoreobject/@ID"/>

      <xsl:for-each select="exslt:node-set($token)/token">
        <xsl:variable name="newStatus" select="text()"/>
        <li class="mir-list-edit-actions mir-list-status-actions">
          <a class="{$class}" href="{$ServletsBaseURL}MIRStateServlet?newState={$newStatus}&amp;id={$id}"
             title="{i18n:translate(concat('mir.workflow.state.', $currentStatus, '2', $newStatus,'.message'))}">
            <xsl:value-of select="i18n:translate(concat('mir.workflow.state.', $currentStatus, '2', $newStatus))"/>
          </a>
        </li>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>