<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">

	<!--
	<head>
		<style>
			td {text-align:center;} 
		</style>
	</head>
-->
  <html>

	<!--


-->
<xsl:variable name="user">
	<xsl:value-of select="/scan/@user"/>
</xsl:variable>

<xsl:variable name="bgColor"><xsl:choose>
<xsl:when test="$user = 'root'">#E61616</xsl:when>
<xsl:otherwise>#00B800</xsl:otherwise>
</xsl:choose></xsl:variable >


<xsl:variable name="tbColor"><xsl:choose>
<xsl:when test="$user = 'root'">#FF3333</xsl:when>
<xsl:otherwise>#9acd32</xsl:otherwise>
</xsl:choose></xsl:variable >

	<head>


	</head>

<body bgcolor="{$bgColor}">

	<h2>Scan of "<u><xsl:value-of select="/scan/@system"/></u>"</h2>
<xsl:value-of select="/scan/@date"/>

<p>Scanned as User: <i><b> <xsl:copy-of select="$user" /> </b></i></p>


<br/>
  <xsl:for-each select="/scan/group">
<br/>
	<xsl:variable name="g_title">
	<xsl:value-of select="./@title"/>
	</xsl:variable>

	<a href="#{$g_title}"> <xsl:value-of select="./@title"/></a>

</xsl:for-each>

<br/>
  <xsl:for-each select="/scan/group">
	<xsl:variable name="g_title">
	<xsl:value-of select="./@title"/>
	</xsl:variable>
	<a name="{$g_title}"/>
	<h4><xsl:value-of select="@title"/></h4>

  <table border="1" style="width:100%">

    <tr bgcolor="{$tbColor}">
      <th>Command</th>
      <th>Description</th>
	<th> Result </th>
    </tr>
	<xsl:for-each select="data">
    <tr bgcolor="#f8fff8"> <!-- bgcolor="#dcff94" -->
      <td style="width:25% text-align:left"><xsl:value-of select="./command"/></td>
      <td style="width:15% text-align:right"><xsl:value-of select="./description"/></td>
      <td style="width:60% text-align:right"><pre>  <xsl:value-of select="./info"/>  </pre></td>

    </tr>
	 </xsl:for-each>

  </table>
  </xsl:for-each>

<p>credits to: <a href="http://www.rebootuser.com/?p=1623#.Vj3Yqm9qyRt" target="_blank">www.rebootuser.com page</a>
for most commands and descriptions</p>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet> 
