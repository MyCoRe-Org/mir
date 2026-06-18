<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:miraccesskeyutil="http://www.mycore.de/xslt/miraccesskeyutil"
  xmlns:mirstrutils="http://www.mycore.de/xslt/mirstrutils"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template name="objectLink">
    <xsl:param name="obj_id" />
    <xsl:param name="mcrobj" />

    <xsl:choose>
      <xsl:when test="$mcrobj">
        <xsl:variable name="resolved_obj_id" select="$mcrobj/@ID" />
        <xsl:choose>
          <xsl:when test="mcracl:check-permission($resolved_obj_id,'read')">
            <a href="{$WebApplicationBaseURL}receive/{$resolved_obj_id}">
              <xsl:attribute name="title">
                <xsl:apply-templates select="$mcrobj" mode="fulltitle" />
              </xsl:attribute>
              <xsl:apply-templates select="$mcrobj" mode="resulttitle" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="LoginURL"
              select="concat($ServletsBaseURL, 'MCRLoginServlet?url=', encode-for-uri(string($RequestURL)))" />
            <xsl:apply-templates select="$mcrobj" mode="resulttitle" />
            <xsl:text>&#160;</xsl:text>
            <a href="{$LoginURL}">
              <img src="{concat($WebApplicationBaseURL,'images/paper_lock.gif')}" />
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="string-length($obj_id)&gt;0">
        <xsl:variable name="resolved_mcrobj" select="document(concat('mcrobject:',$obj_id))/mycoreobject" />
        <xsl:choose>
          <xsl:when test="mcracl:check-permission($obj_id,'read')">
            <a href="{$WebApplicationBaseURL}receive/{$obj_id}">
              <xsl:apply-templates select="$resolved_mcrobj" mode="resulttitle" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="LoginURL"
              select="concat($ServletsBaseURL, 'MCRLoginServlet?url=', encode-for-uri(string($RequestURL)))" />
            <xsl:apply-templates select="$resolved_mcrobj" mode="resulttitle" />
            <xsl:text>&#160;</xsl:text>
            <a href="{$LoginURL}">
              <img src="{concat($WebApplicationBaseURL,'images/paper_lock.gif')}" />
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="displayLogin">
    <xsl:variable name="loginURL" select="concat($ServletsBaseURL, 'MCRLoginServlet?url=', encode-for-uri(string($RequestURL)))" />
    <br></br>
    <xsl:copy-of
      select="
        parse-xml-fragment(
          mcri18n:translate-with-params('mir.loginRequiredInfo', mirstrutils:escape-xml($loginURL))
        )/node()" />
  </xsl:template>

  <xsl:template name="mir.printNotLoggedIn">
    <div class="alert alert-danger">
      <h1>
        <xsl:value-of select="mcri18n:translate('mir.error.headline.401')" />
      </h1>
      <p>
        <xsl:copy-of select="parse-xml-fragment(mcri18n:translate('mir.error.codes.401'))/node()" />
        <xsl:if test="mcracl:is-current-user-guest-user()">
          <xsl:call-template name="displayLogin" />
        </xsl:if>

        <xsl:variable name="object-id" select="miraccesskeyutil:get-object-id-from-url($RequestURL)" />
        <xsl:if test="$object-id != '' and miraccesskeyutil:can-current-user-redeem-access-key($object-id)">
          <br />
          <xsl:call-template name="display-set-access-key">
            <xsl:with-param name="reference" select="$object-id" />
          </xsl:call-template>
        </xsl:if>
      </p>
    </div>
  </xsl:template>

  <xsl:template name="print.writeProtectionMessage">
    <xsl:variable name="websiteWriteProtection" select="document('websiteWriteProtection:')/message" />
    <xsl:if test="$websiteWriteProtection/@active='true'">
      <div class="alert alert-warning alert-dismissable">
        <button type="button" class="btn-close float-end" data-bs-dismiss="alert" aria-hidden="true" />
        <strong>
          <xsl:copy-of select="$websiteWriteProtection/node()" />
        </strong>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="display-set-access-key">
    <xsl:param name="reference" />

    <xsl:variable name="set-access-key-url" select="
      concat($WebApplicationBaseURL, 'accesskey/set.xed', '?objId=', $reference, '&amp;url=', encode-for-uri(string($RequestURL)))
    " />

    <xsl:value-of select="concat(mcri18n:translate('mir.accesskey.setInfo.leading'), ' ')" />
    <a href="{$set-access-key-url}">
      <xsl:value-of select="mcri18n:translate('mir.accesskey.setInfo.link')" />
    </a>
    <xsl:value-of select="concat(' ', mcri18n:translate('mir.accesskey.setInfo.trailing'))" />
  </xsl:template>

</xsl:stylesheet>
