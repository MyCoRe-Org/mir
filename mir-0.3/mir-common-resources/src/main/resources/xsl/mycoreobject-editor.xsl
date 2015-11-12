<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================== -->
<!-- $Revision: 1.4 $ $Date: 2007-04-04 11:32:08 $ -->
<!-- ============================================== -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" exclude-result-prefixes="acl">
  <xsl:include href="mycoreobject.xsl" />
  <!-- overwrite xsl:output of generatePage.xsl -->
  <xsl:output method="xml" encoding="UTF-8" media-type="application/xml" doctype-public="MCRXML" doctype-system="mycoreobject.dtd"/>

  <xsl:attribute-set name="tag">
    <xsl:attribute name="class">
      <xsl:value-of select="./@class" />
    </xsl:attribute>
    <xsl:attribute name="heritable">
      <xsl:value-of select="./@heritable" />
    </xsl:attribute>
    <xsl:attribute name="notinherit">
      <xsl:value-of select="./@notinherit" />
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="/mycoreobject" priority="10">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:copy />
      </xsl:for-each>
      <!-- check the WRITEDB permission -->
      <xsl:if test="not(@ID) or acl:checkPermission(@ID,'writedb')">
        <xsl:if test="structure/parents/parent">
          <structure>
            <parents class="MCRMetaLinkID">
              <xsl:apply-templates select="structure/parents/parent" mode="editor" />
            </parents>
          </structure>
        </xsl:if>
        <metadata xml:lang="de">
          <!-- 
            only copy element for editor not inherited from parent
          -->
          <xsl:for-each select="metadata/*[*/@inherited='0']">
            <xsl:copy use-attribute-sets="tag">
              <xsl:apply-templates select="*[@inherited='0']" mode="editor" />
            </xsl:copy>
            <xsl:value-of select="'&#x0A;'" />
          </xsl:for-each>
        </metadata>
        <xsl:copy-of select="service" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[../@class='MCRMetaClassification']" mode="editor" priority="1">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:copy />
      </xsl:for-each>
      <xsl:attribute name="editor.output">
        <xsl:variable name="classlink">
          <xsl:call-template name="ClassCategLink">
            <xsl:with-param name="classid" select="@classid" />
            <xsl:with-param name="categid" select="@categid" />
            <xsl:with-param name="host" select="'local'" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="document($classlink)/mycoreclass/categories/category">
          <xsl:variable name="selectLang">
            <xsl:call-template name="selectLang">
              <xsl:with-param name="nodes" select="./label" />
            </xsl:call-template>
          </xsl:variable>
          <xsl:for-each select="./label[lang($selectLang)]">
            <xsl:value-of select="@text" />
          </xsl:for-each>
        </xsl:for-each>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[../@class='MCRMetaLinkID']" mode="editor" priority="1">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:copy />
      </xsl:for-each>
      <xsl:attribute name="editor.output">
        <xsl:variable name="mcrobj" select="document(concat('mcrobject:',@xlink:href))" />
        <xsl:apply-templates select="$mcrobj/mycoreobject" mode="resulttitle" />
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[../@class]" mode="editor" priority="0">
    <xsl:copy-of select="." />
  </xsl:template>

</xsl:stylesheet>
